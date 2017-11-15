@testable import DropboxSync

class Mocks {
    lazy var listFiles = ListFilesMock()
    lazy var downloadFiles = DownloadFilesMock()
    lazy var uploadFile = UploadFileMock()
    lazy var sync = SyncMock()
    lazy var dropboxClient = DropboxClientMock()
    lazy var syncCollection = SyncCollectionMock()
    lazy var statusPersistence = StatusPersistenceMock()
}

let mockBrokenMetaFileContents = "{\"updated_at5487226,\"type\":\"Note\",\"uuid\":\"2C7EC60A-6E62-4BF4-9B93-919B18F0E589\"}"
let mockMetaFileContents = "{\"updated_at\":1505487226,\"type\":\"Note\",\"uuid\":\"2C7EC60A-6E62-4BF4-9B93-919B18F0E589\"}"

class ListFilesMock: ListFiles {
    var didFetch = false

    override func fetch(completion: @escaping ListFilesCallback) {
        didFetch = true
        completion(["/fake/path.meta"])
    }
}

class DownloadFilesMock: DownloadFiles {
    var didPerform = false
    var performReturn: [URL] = []

    override func perform(filepaths: [String], completion: @escaping DownloadFilesCompletionHandler) {
        didPerform = true
        completion(performReturn)
    }
}

class UploadFileMock: UploadFile {
    var didPerform = false
    var performRemotePaths: [String] = []
    var shouldSucceed = true
    
    override func perform(remotePath: String, data: Data, completion: @escaping UploadFileCompletionHandler) {
        didPerform = true
        performRemotePaths.append(remotePath)
        completion(shouldSucceed)
    }
}

class SyncMock: Sync {
    var didSync = false
    var didSyncL: SyncCollection!
    var didSyncS: SyncCollection!

    override func perform(completion: @escaping SyncCompletionHandler) {
        didSync = true
        didSyncL = l
        didSyncS = s
        completion(self)
    }

    func didSyncWith(l: SyncCollection, status: SyncCollection) -> Bool {
        return l === didSyncL && s  === didSyncS
    }
}

func mockMetaFile() -> URL {
    let fileManager = FileManager.default
    let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let path = documents.appendingPathComponent("meta.json")
    try! mockMetaFileContents.write(to: path, atomically: true, encoding: .utf8)
    return path
}

func mockBrokenMetaFile() -> URL {
    let fileManager = FileManager.default
    let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let path = documents.appendingPathComponent("meta.json")
    try! mockBrokenMetaFileContents.write(to: path, atomically: true, encoding: .utf8)
    return path
}

class StatusPersistenceMock: StatusPersistence {
    var didRead = false
    var didWrite = false
    var writeArgument: SyncCollection!
    let readReturn = SyncCollection()

    override func read() -> SyncCollection {
        didRead = true
        return readReturn
    }

    override func write(_ collection: SyncCollection) {
        didWrite = true
        writeArgument = collection
    }

    func didWriteWith(_ collection: SyncCollection) -> Bool {
        return didWrite && writeArgument === collection
    }
}

class UserDefaultsMock: UserDefaultsProtocol {
    var objectWasCalled = false
    var setWasCalled = false
    var setWasCalledValue = ""

    func object(forKey: String) -> Any? {
        objectWasCalled = true
        return "1!~!~!~!2!~!~!~!3"
    }

    func set(_ value: Any?, forKey defaultName: String) {
        setWasCalledValue = value as! String
        setWasCalled = true
    }
}

class SyncCollectionMock: SyncCollection {
    override func commitChanges(completion: @escaping SyncCommitCompletionHandler) {
        for deletion in stagingDeletions {
            if let index = store.index(where: { $0.id == deletion }) {
                store.remove(at: index)
            }
        }
        stagingDeletions.removeAll()

        for update in stagingUpdates {
            if let index = store.index(where: { $0.id == update.id }) {
                store.remove(at: index)
            }
            store.append(update)
        }
        stagingUpdates.removeAll()

        for insertion in stagingInserts {
            store.append(insertion)
        }
        stagingInserts.removeAll()

        completion()
    }
}

class SyncElementMock: SyncElement {
    var meta = ""
}
