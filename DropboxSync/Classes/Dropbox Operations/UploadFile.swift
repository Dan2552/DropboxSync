import SwiftyDropbox

typealias UploadFileCompletionHandler = ()->()

class UploadFile {
    private var filepath: String = ""
    private var completion: UploadFileCompletionHandler = { _ in }

    func perform(filepath: String, completion: @escaping UploadFileCompletionHandler) {
        self.filepath = filepath
        self.completion = completion

        let client = Dependency.dropboxClient
        
// let contentPath = "/\(uuid)/content.json"
        // client.files.download(path: filepath, overwrite: true, destination: destinationForDownload(temporaryLocation:response:))

        completion()
    }


}
