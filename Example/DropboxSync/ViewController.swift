//
//  ViewController.swift
//  DropboxSync
//
//  Created by Daniel Green on 07/24/2016.
//  Copyright (c) 2016 Daniel Green. All rights reserved.
//

import UIKit
import DropboxSync
import SwiftyDropbox

class ViewController: UIViewController, DropboxSyncDelegate {
    var collection = [RecordThatNeedsSyncing]()
    
    override func viewDidLoad() {
        // Because this is just an example, we'll create some dummy data here
        // Note: Try commenting out / changing this method to see syncing back from dropbox
        let first = RecordThatNeedsSyncing(stringValue: "first")
        let second = RecordThatNeedsSyncing(stringValue: "second")
        let third = RecordThatNeedsSyncing(stringValue: "third")
        
        collection = [first, second, third]
    }
    
    override func viewDidAppear(animated: Bool) {
        let sync = DropboxSync(delegate: self)
        
        if sync.loggedIn() {
            print("logged in")
            sync.sync(collection)
        } else {
            Dropbox.authorizeFromController(self)
        }
    }
    
    func dropboxSyncFinishedSync() {
        print("finished!")
    }
    
    func dropboxSyncProgressUpdate(progress: Int, total: Int) {
        print("progress: \(progress) of \(total)")
    }
    
}

