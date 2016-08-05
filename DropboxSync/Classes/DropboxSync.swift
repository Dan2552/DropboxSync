//
//  DropboxSync.swift
//  Pods
//
//  Created by Dan on 24/07/2016.
//
//

import Foundation
import SwiftyDropbox
import SwiftyJSON

private enum SyncState {
    case NotStarted
    case FindRemoteFiles
    case DownloadMetadata
    case ReadMetadata
    case QueueRemainingUploads
    case Upload
    case Download
    case Finish
}

public class DropboxSync {
    let delegate: DropboxSyncDelegate
    
    public init(delegate: DropboxSyncDelegate) {
        self.delegate = delegate
    }
    
    public func sync<T: DropboxSyncable>(items: [T]) {
        guard let _ = client else { return }
        guard state == .NotStarted else { return }
        
        self.syncableType = T.self
        
        for item in items {
            syncables.append(item)
        }
        
        next(.FindRemoteFiles)
    }
    
    public func loggedIn() -> Bool {
        if let _ = Dropbox.authorizedClient { return true }
        return false
    }
    
    ////// Private
    
    private var syncableType: DropboxSyncable.Type?
    private var syncables = [DropboxSyncable]()
    private var state: SyncState = .NotStarted
    private var client: DropboxClient? { return Dropbox.authorizedClient }
    private var remoteMetaPaths = [String]()
    private var remoteMetaPathsToDownload = [String]()
    private var remoteMetaPathsToRead = [String]()
    private var idsToUpload = [String]()
    private var idsToDownload = [String]()
    private var idsAlreadySynced = [String]()
    private var progressTotal: Int?

    private func next(state: SyncState) {
        switch state {
        case .FindRemoteFiles:
            findRemoteFiles()
        case .DownloadMetadata:
            downloadMetaFiles()
        case .ReadMetadata:
            readMetaFiles()
        case .QueueRemainingUploads:
            queueRemainingUploads()
        case .Upload:
            setProgressTotal()
            uploadFiles()
        case .Download:
            downloadFiles()
        case .Finish:
            finish()
        default:
            break
        }
    }
    
    private func findRemoteFiles() {
        client!.files.listFolder(path: "", recursive: true).response { response, error in
            if let result = response {
                for entry in result.entries {
                    guard let file = entry as? Files.FileMetadata else { continue }
                    guard file.name == "meta.json" else { continue }
                    
                    self.remoteMetaPaths.append(file.pathLower!)
                    self.remoteMetaPathsToRead.append(file.pathLower!)
                    self.remoteMetaPathsToDownload.append(file.pathLower!)
                }
                
                self.next(.DownloadMetadata)
            } else {
                print(error!)
            }
        }
    }
    
    private func downloadMetaFiles() {
        guard let nextMetaPath = remoteMetaPathsToDownload.popLast() else {
            next(.ReadMetadata)
            return
        }
        
        client!.files.download(path: nextMetaPath, overwrite: true, destination: { _, response in
            let directory = self.directoryFor(nextMetaPath)
            self.createDirectory(directory)
            return directory.URLByAppendingPathComponent("meta.json")
        }).response({ response, error in
            if let e = error { print(e) }
            self.downloadMetaFiles()
        })
    }
    
    private func readMetaFiles() {
        guard let nextMetaPath = remoteMetaPathsToRead.popLast() else {
            next(.QueueRemainingUploads)
            return
        }
        let path = directoryFor(nextMetaPath).URLByAppendingPathComponent("meta.json")

        let json = JSON(data: dataForFile(path))

        if let uuid = json["uuid"].string, let updatedAtInterval = json["updated_at"].double {
            let remoteUpdatedAt = floor(updatedAtInterval)

            var foundLocalSyncable = false
            for syncable in syncables {
                guard syncable.uniqueIdentifier() == uuid else { continue }
                
                foundLocalSyncable = true
                
                let localUpdatedAt = floor(syncable.lastUpdatedDate().timeIntervalSince1970)
                
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
            guard !idsToUpload.contains(syncable.uniqueIdentifier()) else { continue }
            guard !idsToDownload.contains(syncable.uniqueIdentifier()) else { continue }
            guard !idsAlreadySynced.contains(syncable.uniqueIdentifier()) else { continue }
            
            idsToUpload.append(syncable.uniqueIdentifier())
        }
        
        next(.Upload)
    }
    
    private func uploadFiles() {
        DropboxSyncOptions.log("upload:")
        DropboxSyncOptions.log("\(idsToUpload)")
        progressUpdate()
        
        guard let nextUpload = idsToUpload.popLast() else {
            next(.Download)
            return
        }
        
        let syncable = syncables.filter { return $0.uniqueIdentifier() == nextUpload }.first!
        let uuid = syncable.uniqueIdentifier()
        let contentPath = "/\(uuid)/content.json"
        let metaPath = "/\(uuid)/meta.json"
        let data = syncable.serializeForSync()
        
        let meta = [
            "uuid": uuid,
            "updated_at": Int(syncable.lastUpdatedDate().timeIntervalSince1970)
        ]
        let metaData = try! SwiftyJSON.JSON(meta).rawData()
        
        let uploadGroup = dispatch_group_create()
        
        let uploadContent = {
            dispatch_group_enter(uploadGroup)
            self.client!.files.upload(path: contentPath, mode: Files.WriteMode.Overwrite, input: data).response { response, error in
                if let metadata = response {
                    DropboxSyncOptions.log("Uploaded file name: \(metadata.name) - \(contentPath)")
                } else {
                    print(error!)
                }
                dispatch_group_leave(uploadGroup)
            }
        }
        
        let uploadMeta = {
            dispatch_group_enter(uploadGroup)
            self.client!.files.upload(path: metaPath, mode: Files.WriteMode.Overwrite, input: metaData).response { response, error in
                if let metadata = response {
                    DropboxSyncOptions.log("Uploaded file name: \(metadata.name) - \(metaPath)")
                } else {
                    print(error!)
                }
                dispatch_group_leave(uploadGroup)
            }
        }
        
        uploadContent()
        uploadMeta()
        dispatch_group_notify(uploadGroup, dispatch_get_main_queue()) {
            self.next(.Upload)
        }
    }
    
    private func downloadFiles() {
        DropboxSyncOptions.log("download:")
        DropboxSyncOptions.log("\(idsToDownload)")
        progressUpdate()
        
        guard let nextDownload = idsToDownload.popLast() else {
            next(.Finish)
            return
        }
        
        let uuid = nextDownload
        let contentPath = "/\(uuid)/content.json"
        
        client!.files.download(path: contentPath, overwrite: true, destination: { _, response in
            let directory = self.directoryFor(contentPath)
            self.createDirectory(directory)
            return directory.URLByAppendingPathComponent("content.json")
        }).response({ response, error in
            if let e = error { print(e) }
            self.importDownloadedFile(contentPath)
            self.downloadFiles()
        })
    }
    
    private func importDownloadedFile(pathString: String) {
        let path = directoryFor(pathString).URLByAppendingPathComponent("content.json")
        let data = dataForFile(path)
        syncableType!.deserializeForSync(data)
    }
    
    private func finish() {
        delegate.dropboxSyncFinishedSync()
    }

    private func directoryFor(path: String) -> NSURL {
        let components = path.componentsSeparatedByString("/")
        let fileManager = NSFileManager.defaultManager()
        var directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        directoryURL = directoryURL.URLByAppendingPathComponent(components[1])
        return directoryURL
    }
    
    private func createDirectory(url: NSURL) {
        try! NSFileManager.defaultManager().createDirectoryAtPath(url.path!, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func dataForFile(url: NSURL) -> NSData {
        return try! NSData(contentsOfURL: url, options: .DataReadingMappedIfSafe)
    }
    
    private func progressUpdate() {
        guard let total = progressTotal else { return }
        let currentProgress = total - (idsToUpload.count + idsToDownload.count)
        delegate.dropboxSyncProgressUpdate(currentProgress, total: total)
    }
    
    private func setProgressTotal() {
        guard progressTotal == nil else { return }
        progressTotal = idsToUpload.count + idsToDownload.count
    }
}