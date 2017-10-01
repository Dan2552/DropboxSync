import Foundation

open class DropboxSyncOptions {
    /// Enable for DropboxSync to log
    open static var verbose = false
    
    static func log(_ string: String) {
        guard verbose else { return }
        print("DropboxSync --- \(string)")
    }
}
