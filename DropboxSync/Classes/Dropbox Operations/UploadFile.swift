import SwiftyDropbox

typealias UploadFileCompletionHandler = ()->()

class UploadFile {
    private var client: DropboxClientProtocol
    private var filepath: String = ""
    private var completion: UploadFileCompletionHandler = { _ in }

    init(client: DropboxClientProtocol? = nil) {
        self.client = client ?? DropboxClientsManager.authorizedClient!
    }

    func perform(filepath: String, completion: @escaping UploadFileCompletionHandler) {
        self.filepath = filepath
        self.completion = completion

// let contentPath = "/\(uuid)/content.json"
        // client.files.download(path: filepath, overwrite: true, destination: destinationForDownload(temporaryLocation:response:))

        completion()
    }


}
