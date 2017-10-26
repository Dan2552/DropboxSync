// TODO: ...
protocol SyncStore {

}

// TODO: move out
protocol SyncElement {
    var id: String { get }
    var updatedAt: Date { get }
}

typealias SyncCommitCompletionHandler = ()->()
typealias SyncCompletionHandler = (Sync)->()

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
    // TODO: is there a default value to give these to prevent them being optional?
    var l = SyncCollection()
    var r = SyncCollection()
    var s = SyncCollection()
    var conflictResolution: ConflictResolution!

    private var completionHandler: SyncCompletionHandler = { _ in }
    private var currentId = ""

    private var allIds: [String] {
        return l.ids + r.ids + s.ids
    }

    init() {
        // TODO: move l,r,s assignment to perform or vars
    }

    // init(left: SyncCollection, right: SyncCollection, status: SyncCollection, conflictResolution: @escaping ConflictResolution) {
    //     l = left
    //     r = right
    //     s = status
    //     self.conflictResolution = conflictResolution
    // }

    func perform(completion: @escaping SyncCompletionHandler) {
        completionHandler = completion

        for id in allIds {
            currentId = id
            handle()
        }

        commit()
    }

    private func commit(progress: Int = 0) {
        guard progress < 3 else {
            completionHandler(self)
            return
        }

        [l, r, s][progress].commitChanges {
            self.commit(progress: progress + 1)
        }
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
