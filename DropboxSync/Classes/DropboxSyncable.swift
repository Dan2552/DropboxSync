import Foundation

public protocol DropboxSyncable {
    func uniqueIdentifier() -> String
    func lastUpdatedDate() -> Date
    func serializeForSync() -> Data
    static func deserializeForSync(_ data: Data)
}
