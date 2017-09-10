import UIKit
import DropboxSync
import SwiftyDropbox

class ViewController: UIViewController {
    var collection = [RecordThatNeedsSyncing]()
    
    override func viewDidLoad() {
        // Because this is just an example, we'll create some dummy data here
        // Note: Try commenting out / changing this method to see syncing back from dropbox
        let first = RecordThatNeedsSyncing(stringValue: "first")
        let second = RecordThatNeedsSyncing(stringValue: "second")
        let third = RecordThatNeedsSyncing(stringValue: "third")
        
        collection = [first, second, third]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if DropboxSyncAuthorization.loggedIn() {
            print("logged in")
            DropboxSync(collection, delegate: self).sync()
        } else {
            DropboxSyncAuthorization.authorize()
        }
    }
}

extension ViewController: DropboxSyncDelegate {
    func dropboxSyncDidFinish(dropboxSync: DropboxSync) {
        print("finished!")
    }
    
    func dropboxSyncProgressUpdate(dropboxSync: DropboxSync, progress: Int, total: Int) {
        print("progress: \(progress) of \(total)")
    }
}
