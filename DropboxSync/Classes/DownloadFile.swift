import SwiftyDropbox

typealias DownloadFileCompletionHandler = (URL)->()

class DownloadFile {
    let client: DropboxClient
    let filepath: String
    
    private var completion: DownloadFileCompletionHandler
    
    init(client: DropboxClient, filepath: String) {
        self.client = client
        self.filepath = filepath
    }
    
    func perform(completion: @escaping DownloadFileCompletionHandler) {
        self.completion = completion
        
        client.files.download(path: filepath,
                              overwrite: true,
                              destination: destinationForDownload(url:response:))
    }
    
    private func destinationForDownload(temporaryLocation: URL, response: HTTPURLResponse) -> URL {
        let contentPath = "/\(uuid)/content.json"
        let directory = self.directoryFor(contentPath)
        self.createDirectory(directory)
        return directory.appendingPathComponent("content.json")
    }
}
