import UIKit
import DropboxSync

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Options.verbose = true
        DropboxSyncAuthorization.setup(appKey: "zbto7nx2qxfthtd")
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        DropboxSyncAuthorization.handleRedirect(url: url)
        return false
    }
}
