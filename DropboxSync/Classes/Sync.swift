protocol SyncStore {

}

// TODO: protocol
protocol SyncElement {

}

protocol SyncCollection {
    subscript(_ id: String) -> SyncElement? { get }
    var ids: [String] { get }
    func commitChanges()
    func contains(id: String) -> Bool
    func stageInsert(_ element: SyncElement?)
    func stageUpdate(_ element: SyncElement?)
    func stageDeletion(_ id: String)
}

/// This process takes 2 collections (e.g. they could be local & remote) that
/// contain elements identified with a globally unique ID (e.g. a UUID). This
/// class will sync these collections by copying missing items into the other
/// collection and deleted from one collection when they are deleted in the
/// other.
///
/// In order to keep track of items that were previously present, and now
/// are not (i.e. they were deleted), a third collection is required: a record
/// of the previous sync process if one has already occurred - if not, nothing
/// could be present that was already deleted.
class Sync {
    let l: SyncCollection
    let r: SyncCollection
    let s: SyncCollection
    let conflictResolution: ConflictResolution

    private var currentId = ""

    private var allIds: [String] {
        return l.ids + r.ids + s.ids
    }

    init(left: SyncCollection, right: SyncCollection, status: SyncCollection, conflictResolution: @escaping ConflictResolution) {
        l = left
        r = right
        s = status
        self.conflictResolution = conflictResolution
    }

    func perform() {
        for id in allIds {
            currentId = id
            handle()
        }

        [l, r, s].forEach { $0.commitChanges() }
    }

    private func handle() {
        if isOnlyA() {
            // Created on L
            r.stageInsert(l[currentId])
            s.stageInsert(l[currentId])

        } else if isOnlyB() {
            // Created on R
            l.stageInsert(r[currentId])
            s.stageInsert(r[currentId])

        } else if isAWithC() {
            // Deleted on R
            l.stageDeletion(currentId)
            s.stageDeletion(currentId)

        } else if isBWithC() {
            // Deleted on L
            r.stageDeletion(currentId)
            s.stageDeletion(currentId)

        } else if isOnlyC() {
            // Deleted on L and R
            s.stageDeletion(currentId)

        } else if isAWithB() || isAll() {
            // Exists on L and R (and possibly on S)
            let left = l[currentId]!
            let right = r[currentId]!
            
            let result = conflictResolution(left, right)
            if result == .lhs {
                r.stageUpdate(left)
                s.stageUpdate(left)
            } else {
                l.stageUpdate(right)
                s.stageUpdate(right)
            }
        }
    }

    private func isOnlyA() -> Bool {
        return l.contains(id: currentId)
            && !r.contains(id: currentId)
            && !s.contains(id: currentId)
    }

    private func isOnlyB() -> Bool {
        return !l.contains(id: currentId)
            && r.contains(id: currentId)
            && !s.contains(id: currentId)
    }

    private func isAWithC() -> Bool {
        return l.contains(id: currentId)
            && !r.contains(id: currentId)
            && s.contains(id: currentId)
    }

    private func isBWithC() -> Bool {
        return !l.contains(id: currentId)
            && r.contains(id: currentId)
            && s.contains(id: currentId)
    }

    private func isAWithB() -> Bool {
        return l.contains(id: currentId)
            && r.contains(id: currentId)
            && !s.contains(id: currentId)
    }

    private func isOnlyC() -> Bool {
        return !l.contains(id: currentId)
            && !r.contains(id: currentId)
            && s.contains(id: currentId)
    }

    private func isAll() -> Bool {
        return l.contains(id: currentId)
            && r.contains(id: currentId)
            && s.contains(id: currentId)
    }
}











//class LocalCollection: SyncCollection {
//    func stageDeletion(_ id: String) {
//
//    }
//
//    subscript(_: String) -> SyncElement {
//        return SyncElement()
//    }
//
//    var ids: [String] = []
//
//    func contains(id: String) -> Bool {
//        return true
//    }
//
//    func stageInsert(_ element: SyncElement) {
//
//    }
//
//    func commitChanges() {
//
//    }
//}
//
//class RemoteCollection: SyncCollection {
//    func stageDeletion(_ id: String) {
//
//    }
//
//    subscript(_: String) -> SyncElement {
//        return SyncElement()
//    }
//
//    var ids: [String] = []
//
//    func contains(id: String) -> Bool {
//        return true
//    }
//
//    func stageInsert(_ element: SyncElement) {
//
//    }
//
//    func commitChanges() {
//
//    }
//}

//protocol RemoteSyncableClient {
//    func fetchCollection(callback: (RemoteCollection)->())
//}
