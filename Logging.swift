import Foundation
func log(_ string: String) {
    guard Options.verbose else {
        return
    }
    print("DropboxSync --- \(string)")
}
