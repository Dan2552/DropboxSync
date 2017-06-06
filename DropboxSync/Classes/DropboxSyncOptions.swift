import Foundation

open class DropboxSyncOptions {
    open static var verbose = false
    
    static func log(_ string: String) {
        guard verbose else { return }
        print(string)
    }
}
