import SwiftyDropbox

typealias ListFilesCallback = (_ filepaths: [String]) -> Void

/// Fetches a list of files from Dropbox.
class ListFiles {
    private let client: DropboxClientProtocol
    private var filepaths = [String]()
    private var completion: ListFilesCallback = { _ in }

    init() {
        self.client = Dependency.dropboxClient()
    }

    func fetch(completion: @escaping ListFilesCallback) {
        self.completion = completion

        client.files
            .listFolder(path: "", recursive: true)
            .response(completionHandler: handleListFolder)
    }

    private func handleListFolder(response: Files.ListFolderResult?, error: CallError<Files.ListFolderError>?) {
        if let error = error {
            handle(error: error)
            return
        }

        guard let response = response else {
            return
        }

        for entry in response.entries {
            if let file = entry as? Files.FileMetadata, let path = file.pathLower {
                filepaths.append(path)
            }
        }

        if response.hasMore {
            client.files.listFolderContinue(cursor: response.cursor)
        } else {
            completion(filepaths)
        }
    }

    private func handle<T: CustomStringConvertible>(error: CallError<T>) {
        log("\(error)")
    }
}
