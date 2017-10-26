@testable import DropboxSync

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

class SyncMock: Sync {
    var didSync = false

    override func perform(completion: @escaping SyncCompletionHandler) {
        didSync = true
        completion(self)
    }
}

func mockMetaFile() -> URL {
    let fileManager = FileManager.default
    let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let path = documents.appendingPathComponent("meta.json")
    try! mockMetaFileContents.write(to: path, atomically: true, encoding: .utf8)
    return path
}

class StatusPersistenceMock: StatusPersistence {
    var didRead = false
    var didWrite = false

    override func read() -> SyncCollection {
        didRead = true
        return SyncCollection()
    }

    override func write(_ collection: SyncCollection) {
        didWrite = true
    }
}
