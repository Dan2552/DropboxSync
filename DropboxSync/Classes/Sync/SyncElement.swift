import SwiftyJSON

public class SyncElement {
    let id: String
    let updatedAt: Date
    let type: String

    static func from(json: SwiftyJSON.JSON?) -> SyncElement? {
        guard let id = json?["uuid"].string, let updatedAtInterval = json?["updated_at"].double, let type = json?["type"].string else {
            return nil
        }

        let date = Date(timeIntervalSince1970: floor(updatedAtInterval))
        return SyncElement(id: id, type: type, updatedAt: date)
    }

    public init(id: String, type: String, updatedAt: Date) {
        self.id = id
        self.type = type
        self.updatedAt = updatedAt
    }
}
