import Foundation

public protocol DropboxSyncDelegate {
    func dropboxSyncDidFinish(dropboxSync: DropboxSync)
    func dropboxSyncProgressUpdate(dropboxSync: DropboxSync, progress: Int, total: Int)
}
