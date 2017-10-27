import SwiftyJSON

class SyncElement {
    let id: String
    let updatedAt: Date

    static func from(json: SwiftyJSON.JSON?) -> SyncElement? {
        guard let id = json?["uuid"].string, let updatedAtInterval = json?["updated_at"].double else {
            return nil
        }

        let date = Date(timeIntervalSince1970: floor(updatedAtInterval))
        return SyncElement(id: id, updatedAt: date)
    }

    init(id: String, updatedAt: Date) {
        self.id = id
        self.updatedAt = updatedAt
    }
}
