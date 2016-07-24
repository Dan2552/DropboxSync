//
//  Log.swift
//  Pods
//
//  Created by Dan on 30/07/2016.
//
//

import Foundation

public class DropboxSyncOptions {
    public static var verbose = false
    
    static func log(string: String) {
        guard verbose else { return }
        print(string)
    }
}