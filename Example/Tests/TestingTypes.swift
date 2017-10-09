@testable import DropboxSync
import Foundation

class TestingSyncElement: SyncElement {
    let id: String
    var updatedAt: Date = Date(timeIntervalSince1970: 0)
    var meta: String = ""
    
    init(id: String) {
        self.id = id
    }
}

class TestingSyncCollection: SyncCollection {
    convenience init(_ ids: [String]) {
        self.init()
        store = ids.map { TestingSyncElement(id: $0) }
    }
    
    override func commitChanges(completion: SyncCommitCompletionHandler) {
        for deletion in stagingDeletions {
            if let index = store.index(where: { $0.id == deletion }) {
                store.remove(at: index)
            }
        }
        stagingDeletions.removeAll()
        
        for update in stagingUpdates {
            if let index = store.index(where: { $0.id == update.id }) {
                store.remove(at: index)
            }
            store.append(update)
        }
        stagingUpdates.removeAll()
        
        for insertion in stagingInserts {
            store.append(insertion)
        }
        stagingInserts.removeAll()
        
        completion()
    }
}
