import SwiftyDropbox

// TODO: failure?
typealias DownloadFileCompletionHandler = (URL)->()

class DownloadFile {
    private let client: DropboxClientProtocol
    private let filepath: String
    private var completion: DownloadFileCompletionHandler = { _ in }

    init(client: DropboxClientProtocol, filepath: String) {
        self.client = client
        self.filepath = filepath
    }

    func perform(completion: @escaping DownloadFileCompletionHandler) {
        self.completion = completion

        client.files.download(path: filepath, overwrite: true, destination: destinationForDownload(temporaryLocation:response:))
    }

    private func destinationForDownload(temporaryLocation: URL, response: HTTPURLResponse) -> URL {
        // TODO
        return documents()
//        let contentPath = "/\(uuid)/content.json"
//        let directory = self.directoryFor(contentPath)
//        self.createDirectory(directory)
//        return directory.appendingPathComponent("content.json")
    }

    private func documents() -> URL {
        let fileManager = FileManager.default
        return fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
