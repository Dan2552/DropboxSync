class SyncCollection {
    var store = [SyncElement]()
    var stagingInserts = [SyncElement]()
    var stagingUpdates = [SyncElement]()
    var stagingDeletions = [String]()
    
    subscript(_ id: String) -> SyncElement? {
        return store.first { $0.id == id }
    }
    
    var ids: [String] {
        return store.map { $0.id }
    }
    
    func commitChanges(completion: SyncCommitCompletionHandler) {
        fatalError("Commit changes must be overriden")
    }
    
    func contains(id: String) -> Bool {
        return store.contains { $0.id == id }
    }
    
    func stageInsert(_ element: SyncElement?) {
        guard let element = element else {
            return
        }
        stagingInserts.append(element)
    }
    
    func stageUpdate(_ element: SyncElement?) {
        guard let element = element else {
            return
        }
        stagingUpdates.append(element)
    }
    
    func stageDeletion(_ id: String) {
        stagingDeletions.append(id)
    }
}
