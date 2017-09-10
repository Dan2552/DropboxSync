import Foundation
import DropboxSync
import SwiftyJSON

class RecordThatNeedsSyncing {
    var stringValue: String
    
    required init(stringValue: String) {
        self.stringValue = stringValue
    }
}

extension RecordThatNeedsSyncing: DropboxSyncable {
    func syncableUniqueIdentifier() -> String {
        // Here you would normally return a persisted unique id (e.g. a UUID)
        return stringValue
    }
    
    func syncableUpdatedAt() -> Date {
        return Date()
    }
    
    func syncableSerialize() -> Data {
        let json = JSON([ "stringValue": stringValue ])
        return try! json.rawData()
    }
    
    static func syncableDeserialize(_ data: Data) {
        let json = JSON(data: data)
        let stringValue = json["stringValue"].string!
        
        let instance = self.init(stringValue: stringValue)
        // You could persist the derserialized object here
        print(instance.stringValue)
    }
    
    static func syncableDelete(uniqueIdentifier: String) {
        // Here you would delete the persisted record if it exists
    }
}
