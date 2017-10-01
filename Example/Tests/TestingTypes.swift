@testable import DropboxSync
import Foundation

class TestingSyncElement: SyncElement {
    let id: String
    var meta: String = ""
    
    init(id: String) {
        self.id = id
    }
}

class TestingSyncCollection: SyncCollection {
    var store = [TestingSyncElement]()
    var stagingInserts = [TestingSyncElement]()
    var stagingUpdates = [TestingSyncElement]()
    var stagingDeletions = [String]()
    
    init(_ ids: [String]) {
        store = ids.map { TestingSyncElement(id: $0) }
    }
    
    subscript(_ id: String) -> SyncElement? {
        return store.first { $0.id == id }
    }
    
    var ids: [String] {
        return store.map { $0.id }
    }
    
    func commitChanges() {
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
    }
    
    func contains(id: String) -> Bool {
        return self[id] != nil
    }
    
    func stageInsert(_ element: SyncElement?) {
        guard let element = element as? TestingSyncElement else {
            return
        }
        stagingInserts.append(element)
    }
    
    func stageUpdate(_ element: SyncElement?) {
        guard let element = element as? TestingSyncElement else {
            return
        }
        stagingUpdates.append(element)
    }
    
    func stageDeletion(_ id: String) {
        stagingDeletions.append(id)
    }
}
