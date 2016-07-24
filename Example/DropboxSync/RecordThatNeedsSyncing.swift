//
//  RecordThatNeedsSyncing.swift
//  DropboxSync
//
//  Created by Dan on 24/07/2016.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import DropboxSync
import SwiftyJSON

class RecordThatNeedsSyncing: DropboxSyncable {
    var stringValue: String
    
    required init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    func uniqueIdentifier() -> String {
        // Here you would normally return a persisted unique id (e.g. a UUID)
        return stringValue
    }
    
    func lastUpdatedDate() -> NSDate {
        return NSDate()
    }
    
    func serializeForSync() -> NSData {
        let json = JSON([ "stringValue": stringValue ])
        return try! json.rawData()
    }

    static func deserializeForSync(data: NSData) -> Self {
        let json = JSON(data: data)
        let stringValue = json["stringValue"].string!
        
        let instance = self.init(stringValue: stringValue)
        // You could persist the derserialized object here
        print(instance.stringValue)
        return instance
    }
}