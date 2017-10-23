@testable import DropboxSync

class ListFilesMock: ListFiles {
    var didFetch = false

    override func fetch(completion: @escaping ListFilesCallback) {
        didFetch = true
        completion(["/fake/path.meta"])
    }
}

class DownloadFilesMock: DownloadFiles {
    var didPerform = false
    var performReturn = [URL(string: "abc")!]

    override func perform(filepaths: [String], completion: @escaping DownloadFilesCompletionHandler) {
        didPerform = true
        completion(performReturn)
    }
}

class SyncMock: Sync {
    var didSync = false

    override func perform(completion: @escaping SyncCompletionHandler) {
        didSync = true
    }
}
