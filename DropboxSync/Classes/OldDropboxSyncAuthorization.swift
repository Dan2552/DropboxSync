import SwiftyDropbox

public class DropboxSyncAuthorization {
    /// Check if logged in to Dropbox
    public class func loggedIn() -> Bool {
        if let _ = DropboxClientsManager.authorizedClient { return true }
        return false
    }
    
    /// Setup the Dropbox client. Alias of `DropboxClientsManager.setupWithAppKey`.
    public class func setup(appKey: String) {
        DropboxClientsManager.setupWithAppKey(appKey)
    }
    
    /// To be called from AppDelegate when a redirect happens.
    ///
    /// For more control, use `DropboxClientsManager.handleRedirectURL`
    public class func handleRedirect(url: URL) {
        if let authResult = DropboxClientsManager.handleRedirectURL(url) {
            switch authResult {
            case .success:
                DropboxSyncOptions.log("Success! User is logged into Dropbox.")
            case .cancel:
                DropboxSyncOptions.log("Authorization flow was manually canceled by user!")
            case .error(_, let description):
                DropboxSyncOptions.log("Error: \(description)")
            }
        }
    }
    
    /// A convenience method to authorize with Dropbox.
    ///
    /// In order to simpify the authorization call, assumptions are made
    /// - The application is accessible by `UIApplication.shared`
    /// - The topmost ViewController is the one which you want to authorize from
    /// - The openURL action is `UIApplication.shared.openURL(url)`
    ///
    /// If you want to be explicit, you can alternatively use `DropboxClientsManager.authorizeFromController`.
    public class func authorize() {
        guard !loggedIn() else {
            DropboxSyncOptions.log("Already signed in")
            return
        }
        
        let application = UIApplication.shared
        let controller = findBestViewController(rootViewController())
        let openUrl = { (url: URL) -> Void in
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
        DropboxClientsManager.authorizeFromController(application, controller: controller, openURL: openUrl)
    }
}

fileprivate func rootViewController() -> UIViewController? {
    return UIApplication.shared.keyWindow?.rootViewController
}

fileprivate func findBestViewController(_ vc: UIViewController?) -> UIViewController {
    guard let vc = vc else {
        fatalError("Cannot find presented view controller.")
    }
    
    if let presented = vc.presentedViewController {
        return findBestViewController(presented)
    }
    
    if let split = vc as? UISplitViewController {
        // Return right-hand side
        if split.viewControllers.count > 0 {
            return findBestViewController(split.viewControllers.last)
        } else {
            return split
        }
    }
    
    if let navigation = vc as? UINavigationController {
        // Return top view
        if navigation.viewControllers.count > 0 {
            return findBestViewController(navigation.topViewController)
        } else {
            return navigation
        }
    }
    
    if let tabBar = vc as? UITabBarController {
        if (tabBar.viewControllers ?? []).count > 0 {
            return findBestViewController(tabBar.selectedViewController)
        } else {
            return tabBar
        }
    }
    
    return vc
}
