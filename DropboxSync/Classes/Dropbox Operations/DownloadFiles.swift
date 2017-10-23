import SwiftyDropbox

typealias DownloadFilesCompletionHandler = ([URL])->()

class DownloadFiles {
    let client: DropboxClientProtocol
    var filepaths: [String] = []
    private var urls: [URL] = []
    private var completionHandler: DownloadFilesCompletionHandler = { _ in }
    
    init(client: DropboxClientProtocol) {
        self.client = client
    }
    
    func perform(filepaths: [String], completion: @escaping DownloadFilesCompletionHandler) {
        self.filepaths = filepaths
        completionHandler = completion
        downloadFiles()
    }
    
    func downloadFiles(index: Int = 0) {
        guard index < filepaths.count else {
            completionHandler(urls)
            return
        }
        
        let filepath = filepaths[index]
        
        DownloadFile(client: client, filepath: filepath).perform { url in
            self.urls.append(url)
            self.downloadFiles(index: index + 1)
        }
    }
}
