import Foundation
import SwiftyDropbox
import SwiftyJSON

private enum SyncState {
    case notStarted
    case findRemoteFiles
    case downloadMetadata
    case readMetadata
    case queueRemainingUploads
    case delete
    case upload
    case download
    case finish
}

open class DropboxSync {
    var delegate: DropboxSyncDelegate?
    var items: [DropboxSyncable]

    public init<T: DropboxSyncable, S: Sequence>(_ items: S) where S.Iterator.Element == T {
        self.items = Array(items)
        self.syncableType = T.self
    }
    
    convenience public init<T: DropboxSyncable, S: Sequence>(_ items: S, delegate: DropboxSyncDelegate) where S.Iterator.Element == T {
        self.init(items)
        self.delegate = delegate
    }
    
    open func sync() {
        DropboxSyncOptions.log("Sync starting")
        guard DropboxSyncAuthorization.loggedIn(), state == .notStarted else {
            DropboxSyncOptions.log("Failed to start. Logged in? Already running?")
            return
        }

        progressTotal = nil
        
        for item in items {
            syncables.append(item)
        }
        
        next(.findRemoteFiles)
    }

    ////// Private
    
    private var syncableType: DropboxSyncable.Type
    private var syncables = [DropboxSyncable]()
    private var state: SyncState = .notStarted
    private var client: DropboxClient! { return DropboxClientsManager.authorizedClient }
    private var remoteMetaPaths = [String]()
    private var remoteMetaPathsToDownload = [String]()
    private var remoteMetaPathsToRead = [String]()
    private var idsToDelete = [String]()
    private var idsToUpload = [String]()
    private var idsToDownload = [String]()
    private var idsAlreadySynced = [String]()
    private var progressTotal: Int?

    private func next(_ state: SyncState) {
        switch state {
        case .findRemoteFiles:
            findRemoteFiles()
        case .downloadMetadata:
            downloadMetaFiles()
        case .readMetadata:
            readMetaFiles()
        case .queueRemainingUploads:
            queueRemainingUploads()
        case .delete:
            setProgressTotal()
            delete()
        case .upload:
            uploadFiles()
        case .download:
            downloadFiles()
        case .finish:
            finish()
        default:
            break
        }
    }
    
    private func findRemoteFiles() {
        DropboxSyncOptions.log("Finding remote files")
        client.files.listFolder(path: "", recursive: true, includeDeleted: true).response { response, error in
            if let result = response {
                for entry in result.entries {
                    if let file = entry as? Files.FileMetadata {
                        guard file.name == "meta.json" else { continue }
                        
                        self.remoteMetaPaths.append(file.pathLower!)
                        self.remoteMetaPathsToRead.append(file.pathLower!)
                        self.remoteMetaPathsToDownload.append(file.pathLower!)
                    }
                    
                    if let deletedFile = entry as? Files.DeletedMetadata {
                        guard deletedFile.name == "meta.json" else { continue }
                        let path = deletedFile.pathDisplay!
                        self.idsToDelete.append(path.components(separatedBy: "/")[1])
                    }
                }
                
                if result.hasMore {
                    self.client.files.listFolderContinue(cursor: result.cursor)
                } else {
                    self.next(.downloadMetadata)
                }
            } else {
                print(error!)
            }
        }
    }
    
    private func downloadMetaFiles() {
        DropboxSyncOptions.log("Downloading meta")
        guard let nextMetaPath = remoteMetaPathsToDownload.popLast() else {
            next(.readMetadata)
            return
        }
        
        let directory = self.directoryFor(nextMetaPath)
        self.createDirectory(directory)
        let destinationURL = directory.appendingPathComponent("meta.json")
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destinationURL
        }
        
        client.files.download(path: nextMetaPath, overwrite: true, destination: destination)
            .response { response, error in
                if let e = error { print(e) }
                self.downloadMetaFiles()
            }
    }
    
    private func readMetaFiles() {
        DropboxSyncOptions.log("Reading meta")
        guard let nextMetaPath = remoteMetaPathsToRead.popLast() else {
            next(.queueRemainingUploads)
            return
        }
        let path = directoryFor(nextMetaPath).appendingPathComponent("meta.json")

        let json = JSON(data: dataForFile(path))

        // Check if the "type" in the json matches the type we're syncing.
        //
        // For backwards compatibility, if we don't have a metaType, we can ignore it
        if let metaType = json["type"].string, metaType != "\(syncableType)" {
            return readMetaFiles()
        }
        
        if let uuid = json["uuid"].string, let updatedAtInterval = json["updated_at"].double {
            let remoteUpdatedAt = floor(updatedAtInterval)

            var foundLocalSyncable = false
            for syncable in syncables {
                guard syncable.syncableUniqueIdentifier() == uuid else { continue }
                
                foundLocalSyncable = true
                
                let localUpdatedAt = floor(syncable.syncableUpdatedAt().timeIntervalSince1970)
                
                if localUpdatedAt > remoteUpdatedAt {
                    idsToUpload.append(uuid)
                } else if localUpdatedAt < remoteUpdatedAt {
                    idsToDownload.append(uuid)
                } else {
                    idsAlreadySynced.append(uuid)
                }
            }
            if !foundLocalSyncable {
                idsToDownload.append(uuid)
            }
        } else {
            print("WARNING: metadata parse failed. Ignoring. (\(nextMetaPath))")
        }
        
        readMetaFiles()
    }

    private func queueRemainingUploads() {
        // Any local items that exist that aren't already marked for syncing, must not yet exist on the remote end
        for syncable in syncables {
            guard !idsToUpload.contains(syncable.syncableUniqueIdentifier()) else { continue }
            guard !idsToDownload.contains(syncable.syncableUniqueIdentifier()) else { continue }
            guard !idsAlreadySynced.contains(syncable.syncableUniqueIdentifier()) else { continue }
            guard !idsToDelete.contains(syncable.syncableUniqueIdentifier()) else { continue }
            
            idsToUpload.append(syncable.syncableUniqueIdentifier())
        }
        
        next(.delete)
    }
    
    private func uploadFiles() {
        DropboxSyncOptions.log("upload:")
        DropboxSyncOptions.log("\(idsToUpload)")
        progressUpdate()
        
        guard let nextUpload = idsToUpload.popLast() else {
            next(.download)
            return
        }
        
        let syncable = syncables.filter { return $0.syncableUniqueIdentifier() == nextUpload }.first!
        let uuid = syncable.syncableUniqueIdentifier()
        let contentPath = "/\(uuid)/content.json"
        let metaPath = "/\(uuid)/meta.json"
        let data = syncable.syncableSerialize()
        
        
        
        let meta = [
            "uuid": uuid,
            "updated_at": Int(syncable.syncableUpdatedAt().timeIntervalSince1970),
            "type": "\(syncableType)"
        ] as [String : Any]
        let metaData = try! SwiftyJSON.JSON(meta).rawData()
        
        let uploadGroup = DispatchGroup()
        
        let uploadContent = {
            uploadGroup.enter()
            self.client.files.upload(path: contentPath, mode: Files.WriteMode.overwrite, input: data).response { response, error in
                if let metadata = response {
                    DropboxSyncOptions.log("Uploaded file name: \(metadata.name) - \(contentPath)")
                } else {
                    print(error!)
                }
                uploadGroup.leave()
            }
        }
        
        let uploadMeta = {
            uploadGroup.enter()
            self.client.files.upload(path: metaPath, mode: Files.WriteMode.overwrite, input: metaData).response { response, error in
                if let metadata = response {
                    DropboxSyncOptions.log("Uploaded file name: \(metadata.name) - \(metaPath)")
                } else {
                    print(error!)
                }
                uploadGroup.leave()
            }
        }
        
        uploadContent()
        uploadMeta()
        uploadGroup.notify(queue: DispatchQueue.main) {
            self.next(.upload)
        }
    }
    
    private func downloadFiles() {
        DropboxSyncOptions.log("download:")
        DropboxSyncOptions.log("\(idsToDownload)")
        progressUpdate()
        
        guard let nextDownload = idsToDownload.popLast() else {
            next(.finish)
            return
        }
        
        let uuid = nextDownload
        let contentPath = "/\(uuid)/content.json"
        
        client.files.download(path: contentPath, overwrite: true, destination: { _, response in
            let directory = self.directoryFor(contentPath)
            self.createDirectory(directory)
            return directory.appendingPathComponent("content.json")
        }).response { response, error in
            if let e = error { print(e) }
            self.importDownloadedFile(contentPath)
            self.downloadFiles()
        }
    }
    
    private func delete() {
        DropboxSyncOptions.log("delete: \(idsToDelete)")
        
        for identifier in idsToDelete {
            syncableType.syncableDelete(uniqueIdentifier: identifier)
        }
        
        idsToDelete = []
        
        next(.upload)
    }
    
    private func importDownloadedFile(_ pathString: String) {
        let path = directoryFor(pathString).appendingPathComponent("content.json")
        let data = dataForFile(path)
        syncableType.syncableDeserialize(data)
    }
    
    private func finish() {
        delegate?.dropboxSyncDidFinish(dropboxSync: self)
    }

    private func directoryFor(_ path: String) -> URL {
        let components = path.components(separatedBy: "/")
        let fileManager = FileManager.default
        var directoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        directoryURL = directoryURL.appendingPathComponent(components[1].lowercased())
        return directoryURL
    }
    
    private func createDirectory(_ url: URL) {
        try! FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func dataForFile(_ url: URL) -> Data {
        return try! Data(contentsOf: url, options: .mappedIfSafe)
    }
    
    private func progressUpdate() {
        guard let total = progressTotal else { return }
        let currentProgress = total - (idsToUpload.count + idsToDownload.count + idsToDelete.count)
        delegate?.dropboxSyncProgressUpdate(dropboxSync: self, progress: currentProgress, total: total)
    }
    
    private func setProgressTotal() {
        guard progressTotal == nil else { return }
        progressTotal = idsToUpload.count + idsToDownload.count + idsToDelete.count
    }
}
