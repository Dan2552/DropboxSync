@testable import DropboxSync
import Quick
import Nimble

class SyncProcessSpec: QuickSpec {
    var describedInstance: SyncProcess!
    var client: MockDropboxClient!
    var localCollection: SyncCollection!

    var listFiles: ListFilesMock!
    var downloadFiles: DownloadFilesMock!
    var sync: SyncMock!
    var statusPersistence: StatusPersistenceMock!

    var completionHandler: SyncProcessCompletionHandler!

    var completionHandlerResult: SyncProcessResult?

    func setup() {
        client = client ?? MockDropboxClient()
        localCollection = localCollection ?? SyncCollectionMock()
        completionHandler = completionHandler ?? { result in
            self.completionHandlerResult = result
        }

        listFiles = listFiles ?? ListFilesMock(client: client)
        downloadFiles = downloadFiles ?? DownloadFilesMock(client: client)
        sync = sync ?? SyncMock()
        statusPersistence = statusPersistence ?? StatusPersistenceMock()

        describedInstance = describedInstance ?? SyncProcess(
            listFiles: listFiles,
            downloadFiles: downloadFiles,
            localCollection: localCollection,
            sync: sync
        )

        describedInstance.statusPersistence = statusPersistence
    }

    override func spec() {
        beforeEach {
            self.client = nil
            self.localCollection = nil
            self.completionHandler = nil
            self.listFiles = nil
            self.downloadFiles = nil
            self.sync = nil
            self.describedInstance = nil
            self.statusPersistence = nil
        }

        describe("#perform") {
            func subject() {
                setup()
                describedInstance.perform(completion: completionHandler)
            }

            it("downloads a list of files from Dropbox") {
                subject()
                XCTAssert(self.listFiles.didFetch)
            }

            it("downloads the meta files") {
                subject()
                XCTAssert(self.downloadFiles.didPerform)
            }

            context("no metafiles (i.e. first sync for remote") {
                beforeEach {
                    self.setup()
                    self.downloadFiles.performReturn = []
                }

                it("performs a sync") {
                    subject()
                    XCTAssert(self.sync.didSyncWith(
                        l: self.localCollection,
                        status: self.statusPersistence.readReturn
                    ))
                }

                it("persists the sync status") {
                    subject()
                    XCTAssert(self.statusPersistence.didWriteWith(self.sync.s))
                }

                it("calls completion with .success") {
                    subject()
                    XCTAssert(self.completionHandlerResult == .success)
                }
            }

            context("the downloaded metafiles were readable") {
                beforeEach {
                    self.setup()
                    self.downloadFiles.performReturn = [
                        mockMetaFile()
                    ]
                }

                it("performs a sync") {
                    subject()
                    XCTAssert(self.sync.didSyncWith(
                        l: self.localCollection,
                        status: self.statusPersistence.readReturn
                    ))
                }

                it("persists the sync status") {
                    subject()
                    XCTAssert(self.statusPersistence.didWriteWith(self.sync.s))
                }

                it("calls completion with .success") {
                    subject()
                    XCTAssert(self.completionHandlerResult == .success)
                }
            }

            context("an unreadable metafile is downloaded") {
                beforeEach {
                    self.setup()
                    self.downloadFiles.performReturn = [
                        URL(string: "/invalid/url")!
                    ]
                }

                it("does not perform a sync") {
                    subject()
                    XCTAssert(!self.sync.didSync)
                }

                it("does not persist the sync status") {
                    subject()
                    XCTAssert(!self.statusPersistence.didWrite)
                }

                it("calls completion with failureReadingRemoteMeta") {
                    XCTAssert(self.completionHandlerResult == .failureReadingRemoteMeta)
                }
            }
        }
    }
}
