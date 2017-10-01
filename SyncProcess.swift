import SwiftyDropbox

class DownloadFile {
    init(client: DropboxClient) {
        
    }
    
    func perform(filepath: String, completion: ()->()) {
        
    }
}

/// Process that:
/// - Gets a list of files from Dropbox (using ListFiles class)
/// - Downloads all available meta files (TODO)
/// - Reads the meta files to build a RemoteCollection instance (TODO)
/// - Commits to a sync (using Sync class), resolving conflict by most recently updated
/// - Persists the state of the sync (TODO)
class SyncProcess {
    private let listFiles: ListFiles
    private let downloadFile: DownloadFile
    
    init(client: DropboxClient) {
        listFiles = ListFiles(client: client)
        downloadFile = DownloadFile(client: client)
        
    }
    
    func perform() {
        
    }
}
