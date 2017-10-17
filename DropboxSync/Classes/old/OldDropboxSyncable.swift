import Foundation

public protocol DropboxSyncable {
    // Unique id, e.g. UUID
    func syncableUniqueIdentifier() -> String
    
    // Time the record was last updated
    func syncableUpdatedAt() -> Date
    
    // Serialize + Deserialize to save and load from Dropbox
    // Note: Make sure you don't update your updatedAt when deserializing
    func syncableSerialize() -> Data
    static func syncableDeserialize(_ data: Data)
    
    // Deletes are synced too
    static func syncableDelete(uniqueIdentifier: String)
}
