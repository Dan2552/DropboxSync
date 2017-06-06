import Foundation

public protocol DropboxSyncDelegate {
    func dropboxSyncFinishedSync()
    func dropboxSyncProgressUpdate(_ progress: Int, total: Int)
}
