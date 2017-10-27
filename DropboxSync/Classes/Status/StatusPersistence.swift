import Foundation

protocol UserDefaultsProtocol {
    func object(forKey: String) -> Any?
    func set(_ value: Any?, forKey defaultName: String)
}

extension UserDefaults: UserDefaultsProtocol {
    
}

class StatusPersistence {
    var defaults: UserDefaultsProtocol = UserDefaults.standard
    /// We don't know the format the IDs will be in, so to (lazily :))
    /// persist them in UserDefaults, they are separated using a
    /// set of characters that are unlikely to be used.
    var separator = "!~!~!~!"
    var key = "DropboxSyncPreviousSync"

    func read() -> SyncCollection {
        let str = defaults.object(forKey: key) as? String ?? ""
        let ids = str.components(separatedBy: separator)
        let stagedCollection = SyncCollection()
        stagedCollection.store = ids.map {
            StatusElement(id: $0, updatedAt: Date(timeIntervalSince1970: 0))
        }
        return stagedCollection
    }

    func write(_ collection: SyncCollection) {
        let str = collection.ids.joined(separator: separator)
        defaults.set(str, forKey: key)
    }
}
