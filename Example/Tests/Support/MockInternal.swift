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
    
    override func perform(filepaths: [String], completion: @escaping DownloadFilesCompletionHandler) {
        didPerform = true
        completion([URL(string: "abc")!])
    }
}
