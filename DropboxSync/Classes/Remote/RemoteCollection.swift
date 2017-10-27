// TODO: local collection to save to DB?
// TODO: readme
class RemoteCollection: SyncCollection {
    var commitCompletion: SyncCommitCompletionHandler = {}
    var uploadFile = UploadFile()

    override func commitChanges(completion: @escaping SyncCommitCompletionHandler) {
        self.commitCompletion = completion
        performNextCommit()
    }

    private func performNextCommit() {
        if let nextInsert = stagingInserts.popLast() {
            performInsert(nextInsert)
            return
        }

        if let nextUpdate = stagingUpdates.popLast() {
            performUpdate(nextUpdate)
            return
        }

        if let nextDeletion = stagingDeletions.popLast() {
            performDeletion(nextDeletion)
            return
        }

        commitCompletion()
    }

    private func performInsert(_ element: SyncElement) {
        // TODO: should a SyncElement have an optional path?
        uploadFile.perform(filepath: "todo") {
            self.performNextCommit()
        }
    }

    private func performUpdate(_ element: SyncElement) {
        // TODO: should a SyncElement have an optional path?
        uploadFile.perform(filepath: "todo") {
            self.performNextCommit()
        }
    }

    private func performDeletion(_ id: String) {

        performNextCommit()
    }
}
