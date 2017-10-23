@testable import DropboxSync
import Quick
import Nimble

class SyncProcessSpec: QuickSpec {
    var describedInstance: SyncProcess!
    var client: MockDropboxClient!
    var localCollection: SyncCollection!
    
    var listFiles: ListFilesMock!
    var downloadFiles: DownloadFilesMock!
    
    var completionHandler: SyncProcessCompletionHandler!
    
    func setup() {
        // defaults
        client = client ?? MockDropboxClient()
        localCollection = localCollection ?? TestingSyncCollection()
        completionHandler = completionHandler ?? { _ in }
        
        listFiles = listFiles ?? ListFilesMock(client: client)
        downloadFiles = downloadFiles ?? DownloadFilesMock(client: client)
        
        describedInstance = SyncProcess(
            listFiles: listFiles,
            downloadFiles: downloadFiles,
            localCollection: SyncCollection()
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
            
            it("performs a sync") {
                
            }
            
            it("persists the sync status") {
                
            }
        }
    }
}
