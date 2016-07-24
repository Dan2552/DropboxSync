//
//  DropboxSyncable.swift
//  Pods
//
//  Created by Dan on 24/07/2016.
//
//

import Foundation

public protocol DropboxSyncable {
    func uniqueIdentifier() -> String
    func lastUpdatedDate() -> NSDate
    func serializeForSync() -> NSData
    static func deserializeForSync(data: NSData)
}