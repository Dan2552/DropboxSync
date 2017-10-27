@testable import DropboxSync
import Quick
import Nimble

class RemoteCollectionSpec: QuickSpec {
    var describedInstance = RemoteCollection()
    var uploadFileMock = UploadFileMock()
    var didComplete = false

    override func spec() {
        beforeEach {
            self.uploadFileMock = UploadFileMock()
            self.describedInstance = RemoteCollection()
            self.describedInstance.uploadFile = self.uploadFileMock
            self.didComplete = false
        }

        describe("commitChanges(completion:)") {
            func subject() {
                describedInstance.commitChanges {
                    self.didComplete = true
                }
            }

            context("when there are no staged elements") {
                beforeEach {
                    self.describedInstance.stagingInserts = []
                    self.describedInstance.stagingUpdates = []
                    self.describedInstance.stagingDeletions = []
                }

                it("does not upload anything") {
                    subject()
                    expect(self.uploadFileMock.didPerform).to(beFalse())
                }

                it("does not delete anything") {

                }

                it("calls the completion handler") {
                    subject()
                    expect(self.didComplete).to(beTrue())
                }
            }

            context("when there are staged inserts") {
                beforeEach {
                   self.describedInstance.stagingInserts.append(SyncElement(id: "a", updatedAt: Date()))
                }

                fit("uploads the elements to Dropbox") {
                    subject()
                    expect(self.uploadFileMock.didPerform).to(beTrue())
                    // TODO
                }

                it("clears the staged inserts") {
                    subject()
                    expect(self.describedInstance.stagingInserts.count).to(equal(0))
                }

                it("calls the completion handler") {
                    subject()
                    expect(self.didComplete).to(beTrue())
                }
            }

            context("when there are staged updates") {
                beforeEach {
//                    self.describedInstance.stagingUpdates.append()
                }

                it("uploads the elements to Dropbox") {
                    subject()

                }

                it("clears the staged updates") {
                    subject()
                    expect(self.describedInstance.stagingUpdates.count).to(equal(0))
                }

                it("calls the completion handler") {
                    subject()
                    expect(self.didComplete).to(beTrue())
                }
            }

            context("when there are staged deletions") {
                beforeEach {
//                    self.describedInstance.stagingDeletions.append()
                }

                it("deletes the elements from Dropbox") {
                    subject()

                }

                it("clears the staged deletions") {
                    subject()
                    expect(self.describedInstance.stagingDeletions.count).to(equal(0))
                }

                it("calls the completion handler") {
                    subject()
                    expect(self.didComplete).to(beTrue())
                }
            }

            context("when there are a mix of inserts/updates/deletions") {
                beforeEach {
//                    self.describedInstance.stagingInserts.append()
//                    self.describedInstance.stagingUpdates.append()
//                    self.describedInstance.stagingDeletions.append()
                }

                it("uploads the inserts") {
                    subject()

                }

                it("uploads the updates") {
                    subject()

                }

                it("deletes the deletions") {
                    subject()

                }

                it("clears the staged inserts") {
                    subject()
                    expect(self.describedInstance.stagingInserts.count).to(equal(0))
                }

                it("clears the staged updates") {
                    subject()
                    expect(self.describedInstance.stagingUpdates.count).to(equal(0))
                }

                it("clears the staged deletions") {
                    subject()
                    expect(self.describedInstance.stagingDeletions.count).to(equal(0))
                }

                it("calls the completion handler") {
                    subject()
                    expect(self.didComplete).to(beTrue())
                }
            }
        }
    }
}
