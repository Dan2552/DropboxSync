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
    
    func lastUpdatedDate() -> Date {
        return Date()
    }
    
    func serializeForSync() -> Data {
        let json = JSON([ "stringValue": stringValue ])
        return try! json.rawData()
    }

    static func deserializeForSync(_ data: Data) {
        let json = JSON(data: data)
        let stringValue = json["stringValue"].string!
        
        let instance = self.init(stringValue: stringValue)
        // You could persist the derserialized object here
        print(instance.stringValue)
    }
}
