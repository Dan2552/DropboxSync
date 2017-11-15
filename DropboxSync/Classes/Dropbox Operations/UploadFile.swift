import SwiftyDropbox

typealias UploadFileCompletionHandler = (Bool)->()

class UploadFile {
    func perform(remotePath: String, data: Data, completion: @escaping UploadFileCompletionHandler) {
        let client = Dependency.dropboxClient()

        client.files.upload(path: remotePath, mode: Files.WriteMode.overwrite, input: data).response { response, error in
            if let metadata = response {
                log("Uploaded file name: \(metadata.name) - \(remotePath)")
                completion(true)
            } else {
                if let error = error {
                    log("\(error)")
                } else {
                    log("Upload failed, unknown error")
                }
                completion(false)
            }
        }
    }
}
