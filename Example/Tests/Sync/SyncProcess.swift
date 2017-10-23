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
    
    var completionHandler: SyncProcessCompletionHandler!
    
    var completionHandlerResult: SyncProcessResult?
    
    func setup() {
        // defaults
        client = client ?? MockDropboxClient()
        localCollection = localCollection ?? TestingSyncCollection()
        completionHandler = completionHandler ?? { result in
            self.completionHandlerResult = result
        }
        
        listFiles = listFiles ?? ListFilesMock(client: client)
        downloadFiles = downloadFiles ?? DownloadFilesMock(client: client)
        sync = sync ?? SyncMock()

        describedInstance = SyncProcess(
            listFiles: listFiles,
            downloadFiles: downloadFiles,
            localCollection: SyncCollection(),
            sync: sync
        )
    }
    
    override func spec() {
        beforeEach {
            self.describedInstance = nil
            self.localCollection = nil
            self.client = nil
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
                    self.downloadFiles.performReturn = []
                }

                it("performs a sync") {
                    subject()
                    XCTAssert(self.sync.didSync)
                }
                
                it("persists the sync status") {
                    
                }
                
                it("calls completion with .success") {
                    subject()
                    XCTAssert(self.completionHandlerResult == .success)
                }
            }
            
            context("the downloaded metafiles were readable") {
                
                
                it("performs a sync") {
                    subject()
                    XCTAssert(self.sync.didSync)
                }
                
                it("persists the sync status") {
                    
                }
                
                it("calls completion with .success") {
                    subject()
                    XCTAssert(self.completionHandlerResult == .success)
                }
            }
            
            context("an unreadable metafile is downloaded") {
                it("does not perform a sync") {
                    subject()
                    XCTAssert(!self.sync.didSync)
                } 
                
                it("does not persist the sync status") {
                    
                }
                
                it("calls completion with failureReadingRemoteMeta") {
                    XCTAssert(self.completionHandlerResult == .failureReadingRemoteMeta)
                }
            }
        }
    }
}
