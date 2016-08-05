//
//  DropboxSyncDelegate.swift
//  Pods
//
//  Created by Dan on 24/07/2016.
//
//

import Foundation

public protocol DropboxSyncDelegate {
    func dropboxSyncFinishedSync()
    func dropboxSyncProgressUpdate(progress: Int, total: Int)
}