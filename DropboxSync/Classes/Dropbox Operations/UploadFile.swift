import SwiftyDropbox

typealias UploadFileCompletionHandler = ()->()

class UploadFile {
    // TODO match other classes apis? empty init
    private var client: DropboxClientProtocol?
    private var filepath: String = ""
    private var completion: UploadFileCompletionHandler = { _ in }

    init() {

    }

    func perform(filepath: String, completion: @escaping UploadFileCompletionHandler) {
        self.filepath = filepath
        self.completion = completion

        let client = self.client ?? DropboxClientsManager.authorizedClient!

// let contentPath = "/\(uuid)/content.json"
        // client.files.download(path: filepath, overwrite: true, destination: destinationForDownload(temporaryLocation:response:))

        completion()
    }
    
    
}
