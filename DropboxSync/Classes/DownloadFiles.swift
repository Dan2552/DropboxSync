import SwiftyDropbox

class DownloadFiles {
    let client: DropboxClient
    var filepaths: [String] = []
    
    init(client: DropboxClient) {
        self.client = client
        
    }
    
    func perform(filepaths: [String], completion: ([URL])->()) {
        
    }
}
