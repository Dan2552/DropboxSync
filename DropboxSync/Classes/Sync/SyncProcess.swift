import SwiftyDropbox

protocol DropboxClientProtocol {
    var files: FilesRoutes! { get }
}

// TODO: given this made barely anything error without this
// existing, something must be not using the real client
extension DropboxClient: DropboxClientProtocol {

}

enum SyncProcessResult {
    case success
    case failureReadingRemoteMeta
}

typealias SyncProcessCompletionHandler = (SyncProcessResult)->()
public typealias SyncSerialize = (()->Data)
public typealias SyncDeserialize = ((_ data: Data)->())

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

    private let statusPersistence: StatusPersistence
    private let localCollection: SyncCollection
    private var completion: SyncProcessCompletionHandler = { _ in }

//    convenience init(localCollection: SyncCollection, client: DropboxClientProtocol? = nil) {
//        let client = client ?? DropboxClientsManager.authorizedClient!
//
//        let listFiles = ListFiles(client: client)
//        let downloadFiles = DownloadFiles(client: client)
//
//        self.init(listFiles: listFiles,
//                  downloadFiles: downloadFiles,
//                  localCollection: localCollection,
//                  sync: Sync())
//    }

    private var serialize: SyncSerialize
    private var deserialize: SyncDeserialize
    private var collection: [SyncElement]

    public init(serialize: @escaping SyncSerialize, deserialize: @escaping SyncDeserialize, collection: [SyncElement]) {
        self.serialize = serialize
        self.deserialize = deserialize
        self.collection = collection
        
        localCollection = Dependency.syncCollection()
        localCollection.store = collection
        
        statusPersistence = Dependency.statusPersistence()
    }

    // init(listFiles: ListFiles, downloadFiles: DownloadFiles, localCollection: SyncCollection, sync: Sync) {
    //     self.listFiles = listFiles
    //     self.downloadFiles = downloadFiles
    //     self.localCollection = localCollection
    //     self.sync = sync
    // }

    func perform(completion: SyncProcessCompletionHandler? = nil) {
        if let completion = completion {
            self.completion = completion
        }
        startProcess()
    }

    private func startProcess() {
        Dependency.listFiles().fetch(completion: download(metas:))
    }

    private func download(metas: [String]) {
        let metas = metas.filter { $0.hasSuffix("meta.json") }
        Dependency.downloadFiles().perform(filepaths: metas, completion: buildRemoteCollection(from:))
    }

    private func buildRemoteCollection(from metaFiles: [URL]) {
        let contents = metaFiles
            .map { JSONFileReader().read($0) }
            .map { SyncElement.from(json: $0) }

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
        let sync = Dependency.sync()
        sync.l = localCollection
        sync.r = remoteCollection
        sync.s = statusPersistence.read()
        sync.conflictResolution = conflictResolution

        sync.perform(completion: persistSyncStatus(sync:))
    }

    private func persistSyncStatus(sync: Sync) {
        statusPersistence.write(sync.s)
        completion(.success)
    }
}
