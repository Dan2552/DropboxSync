@testable import DropboxSync
import Quick
import Nimble

class SyncProcessSpec: QuickSpec {
    var describedInstance: SyncProcess!
    var collection: [SyncElement]!

    var mocks: Mocks!

    var serialize: SyncSerialize!
    var deserialize: SyncDeserialize!
    var completionHandler: SyncProcessCompletionHandler!
    var completionHandlerResult: SyncProcessResult?

    func setup() {
        Dependency.dropboxClient = { return self.mocks.dropboxClient }
        Dependency.listFiles = { return self.mocks.listFiles }
        Dependency.downloadFiles = { return self.mocks.downloadFiles }
        Dependency.sync = { return self.mocks.sync }
        Dependency.syncCollection = { return self.mocks.syncCollection }
        Dependency.statusPersistence = { return self.mocks.statusPersistence }

        mocks = mocks ?? Mocks()

        collection = collection ?? []

        serialize = {
            // TODO: spec
            return Data()
        }

        deserialize = { _ in
            // TODO: spec
        }

        completionHandler = completionHandler ?? { result in
            self.completionHandlerResult = result
        }

        describedInstance = SyncProcess(serialize: serialize, deserialize: deserialize, collection: collection)
    }

    override func spec() {
        beforeEach {
            self.serialize = nil
            self.deserialize = nil
            self.completionHandler = nil
            self.describedInstance = nil
            self.mocks = nil
            self.setup()
        }

        describe("#perform") {
            func subject() {
                setup()
                describedInstance.perform(completion: completionHandler)
            }

            it("downloads a list of files from Dropbox") {
                subject()
                XCTAssert(self.mocks.listFiles.didFetch)
            }

            it("downloads the meta files") {
                subject()
                XCTAssert(self.mocks.downloadFiles.didPerform)
            }

            context("no metafiles (i.e. first sync for remote") {
                beforeEach {
                    self.setup()
                    self.mocks.downloadFiles.performReturn = []
                }

                it("performs a sync") {
                    subject()
                    XCTAssert(self.mocks.sync.didSyncWith(
                        l: self.mocks.syncCollection,
                        status: self.mocks.statusPersistence.readReturn
                    ))
                }

                it("persists the sync status") {
                    subject()
                    XCTAssert(self.mocks.statusPersistence.didWriteWith(self.mocks.sync.s))
                }

                it("calls completion with .success") {
                    subject()
                    XCTAssert(self.completionHandlerResult == .success)
                }
            }

            context("the downloaded metafiles were readable") {
                beforeEach {
                    self.mocks.downloadFiles.performReturn = [
                        mockMetaFile()
                    ]
                }

                it("performs a sync") {
                    subject()
                    XCTAssert(self.mocks.sync.didSyncWith(
                        l: self.mocks.syncCollection,
                        status: self.mocks.statusPersistence.readReturn
                    ))
                }

                it("persists the sync status") {
                    subject()
                    XCTAssert(self.mocks.statusPersistence.didWriteWith(self.mocks.sync.s))
                }

                it("calls completion with .success") {
                    subject()
                    XCTAssert(self.completionHandlerResult == .success)
                }
            }

            context("an unreadable metafile is downloaded") {
                beforeEach {
                    self.mocks.downloadFiles.performReturn = [
                        URL(string: "/invalid/url")!
                    ]
                    print("a")
                }

                it("does not perform a sync") {
                    subject()
                    XCTAssert(!self.mocks.sync.didSync)
                }

                it("does not persist the sync status") {
                    subject()
                    XCTAssert(!self.mocks.statusPersistence.didWrite)
                }

                it("calls completion with failureReadingRemoteMeta") {
                    XCTAssert(self.completionHandlerResult == .failureReadingRemoteMeta)
                }
            }
        }
    }
}
