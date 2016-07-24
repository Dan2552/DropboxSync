//
//  AppDelegate.swift
//  DropboxSync
//
//  Created by Daniel Green on 07/24/2016.
//  Copyright (c) 2016 Daniel Green. All rights reserved.
//

import UIKit
import SwiftyDropbox
import DropboxSync

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        DropboxSyncOptions.verbose = true
        Dropbox.setupWithAppKey("zbto7nx2qxfthtd")
        return true
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
            case .Error(let error, let description):
                print("Error \(error): \(description)")
            }
        }
        return false
    }
}
