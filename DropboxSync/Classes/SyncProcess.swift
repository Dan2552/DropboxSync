import SwiftyDropbox

class DownloadFiles {
    let client: DropboxClient
    var filepaths: [String] = []
    
    init(client: DropboxClient) {
        self.client = client
        
    }
    
    func perform(filepaths: [String], completion: ([URL])->()) {
        
    }
}

class DownloadFile {
    init(client: DropboxClient, filepath: String) {
        
    }
    
    func perform(completion: ()->()) {
        
    }
}

class RemoteCollection: SyncCollection {
//    func commitChanges(completion: () -> ()) {
//
//    }
//
//    let collection: [RemoteElement]
//
//    init(collection: [RemoteElement]) {
//        self.collection = collection
//    }
//
//    var ids: [String] {
//        return collection.map { $0.id }
//    }
//
//    subscript(_ id: String) -> SyncElement? {
//        return collection.first { $0.id == id }
//    }
//
//    // TODO: could be an extension method
//    func contains(id: String) -> Bool {
//        return self[id] != nil
//    }
//
//    func stageInsert(_ element: SyncElement?) {
//
//    }
//
//    func stageUpdate(_ element: SyncElement?) {
//
//    }
//
//    func stageDeletion(_ id: String) {
//
//    }
//
//    private func findRemoteFiles() {
//
//    }
}

import SwiftyJSON
class JSONFileReader {
    func read(_ fileUrl: URL) -> SwiftyJSON.JSON? {
        guard let data = dataForFile(fileUrl) else {
            return nil
        }

        return JSON(data: data)
    }
    
    private func dataForFile(_ url: URL) -> Data? {
        do {
            return try Data(contentsOf: url, options: .mappedIfSafe)
        } catch {
            return nil
        }
    }
}

class RemoteElement: SyncElement {
    let id: String
    let updatedAt: Date
    
    static func from(json: SwiftyJSON.JSON?) -> RemoteElement? {
        guard let id = json?["uuid"].string, let updatedAtInterval = json?["updated_at"].double else {
            return nil
        }

        let date = Date(timeIntervalSince1970: floor(updatedAtInterval))
        return RemoteElement(id: id, updatedAt: date)
    }
    
    init(id: String, updatedAt: Date) {
        self.id = id
        self.updatedAt = updatedAt
    }
}

class SyncCollection {
    var store = [SyncElement]()
    var stagingInserts = [SyncElement]()
    var stagingUpdates = [SyncElement]()
    var stagingDeletions = [String]()
    
    subscript(_ id: String) -> SyncElement? {
        return store.first { $0.id == id }
    }
    
    var ids: [String] {
        return store.map { $0.id }
    }
    
    func commitChanges(completion: SyncCommitCompletionHandler) {
        fatalError("Commit changes must be overriden")
    }
    
    func contains(id: String) -> Bool {
        return store.contains { $0.id == id }
    }
    
    func stageInsert(_ element: SyncElement?) {
        guard let element = element else {
            return
        }
        stagingInserts.append(element)
    }
    
    func stageUpdate(_ element: SyncElement?) {
        guard let element = element else {
            return
        }
        stagingUpdates.append(element)
    }
    
    func stageDeletion(_ id: String) {
        stagingDeletions.append(id)
    }
}

//class StatusCollection: SyncCollection {
//    var store = [String]()
//    var stagingInserts = [String]()
//    var stagingUpdates = [String]()
//    var stagingDeletions = [String]()
//
//    var ids: [String] {
//        return store.map { $0 }
//    }
//
//    subscript(id: String) -> SyncElement? {
//        return store[id]
//    }
//
//    func commitChanges(completion: () -> ()) {
//        <#code#>
//    }
//
//    func contains(id: String) -> Bool {
//        <#code#>
//    }
//
//    func stageInsert(_ element: SyncElement?) {
//        <#code#>
//    }
//
//    func stageUpdate(_ element: SyncElement?) {
//        <#code#>
//    }
//
//    func stageDeletion(_ id: String) {
//        <#code#>
//    }
//}

struct StatusElement: SyncElement {
    let id: String
    let updatedAt: Date
}

enum SyncProcessResult {
    case success
    case failureReadingRemoteMeta
}

class StatusPersistence {
    var defaults = UserDefaults.standard
    /// We don't know the format the IDs will be in, so to (lazily :))
    /// persist them in UserDefaults, they are separated using a
    /// set of characters that are unlikely to be used.
    var separator = "!~!~!~!"
    var key = "DropboxSyncPreviousSync"
    
    func read() -> SyncCollection {
        let str = defaults.object(forKey: key) as? String ?? ""
        let ids = str.components(separatedBy: separator)
        let stagedCollection = SyncCollection()
        stagedCollection.store = ids.map {
            StatusElement(id: $0, updatedAt: Date(timeIntervalSince1970: 0))
        }
        return stagedCollection
    }
    
    func write(collection: SyncCollection) {
        let str = collection.ids.joined(separator: separator)
        defaults.set(str, forKey: key)
    }
}

typealias SyncProcessCompletionHandler = (SyncProcessResult)->()

/// Process that:
/// - Gets a list of files from Dropbox (using ListFiles class)
/// - Downloads all available meta files (TODO)
/// - Reads the meta files to build a RemoteCollection instance (TODO)
/// - Commits to a sync (using Sync class), resolving conflict by most recently updated
/// - Persists the state of the sync (TODO)
class SyncProcess {
    /// The conflict resolution used in the sync process. By default
    /// it will use #updatedAt to compare for the side with the most
    /// recent updates.
    var conflictResolution: ConflictResolution = { local, remote in
        // TODO
//        if local.updatedAt <= remote.updatedAt {
            return .lhs
//        } else {
//            return .rhs
//        }
    }
    
    private let listFiles: ListFiles
    private let downloadFiles: DownloadFiles
    private let localCollection: SyncCollection
    private var completion: SyncProcessCompletionHandler = { _ in }

    init(client: DropboxClient, localCollection: SyncCollection) {
        listFiles = ListFiles(client: client)
        downloadFiles = DownloadFiles(client: client)
        self.localCollection = localCollection
    }
    
    func perform(completion: SyncProcessCompletionHandler? = nil) {
        if let completion = completion {
            self.completion = completion
        }
        startProcess()
    }
    
    private func startProcess() {
        listFiles.fetch(completion: download(metas:))
    }
    
    private func download(metas: [String]) {
        let metas = metas.filter { $0.hasSuffix("meta.json") }
        downloadFiles.perform(filepaths: metas, completion: buildRemoteCollection(from:))
    }
    
    private func buildRemoteCollection(from metaFiles: [URL]) {
        let contents = metaFiles
            .map { JSONFileReader().read($0) }
            .map { RemoteElement.from(json: $0) }
        
        // If any meta files failed to read, we don't want to continue sync
        // otherwise we may incorrectly sync over the remote file.
        if contents.contains(where: { $0 == nil }) {
            completion(.failureReadingRemoteMeta)
            return
        }
        
        let remoteCollection = RemoteCollection()
        remoteCollection.store = contents.map { $0! }
        
        sync(remoteCollection)
    }
    
    private func sync(_ remoteCollection: RemoteCollection) {
        let status = StatusPersistence().read()
        let sync = Sync(left: localCollection,
                        right: remoteCollection,
                        status: status,
                        conflictResolution: conflictResolution)
        
        sync.perform(completion: persistSyncStatus(sync:))
    }
    
    private func persistSyncStatus(sync: Sync) {
        StatusPersistence().write(collection: sync.s)
        completion(.success)
    }
}
