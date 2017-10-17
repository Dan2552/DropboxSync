import SwiftyDropbox

enum SyncProcessResult {
    case success
    case failureReadingRemoteMeta
}

typealias SyncProcessCompletionHandler = (SyncProcessResult)->()

/// Process that:
/// - Gets a list of files from Dropbox (using ListFiles class)
/// - Downloads all available meta files
/// - Reads the meta files to build a RemoteCollection instance
/// - Commits to a sync (using Sync class), resolving conflict by most recently updated
/// - Persists the state of the sync
class SyncProcess {
    /// The conflict resolution used in the sync process. By default
    /// it will use #updatedAt to compare for the side with the most
    /// recent updates.
    var conflictResolution: ConflictResolution = { local, remote in
        if local.updatedAt <= remote.updatedAt {
            return .lhs
        } else {
            return .rhs
        }
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