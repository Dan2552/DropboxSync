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

    func commitChanges(completion: @escaping SyncCommitCompletionHandler) {
        fatalError("Commit changes must be overriden")
    }

    func contains(id: String) -> Bool {
        return store.contains { $0.id == id }
    }
}
