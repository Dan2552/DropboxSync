import UIKit
import SwiftyDropbox
import DropboxSync

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        DropboxSyncOptions.verbose = true
        DropboxClientsManager.setupWithAppKey("zbto7nx2qxfthtd")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
            case .error(let error, let description):
                print("Error \(error): \(description)")
            case .cancel:
                print("Cancelled")
            }
        }
        return false
    }
}
