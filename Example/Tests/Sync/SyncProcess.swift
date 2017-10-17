@testable import DropboxSync
import Quick
import Nimble

class SyncProcessSpec: QuickSpec {
    var describedInstance: SyncProcess!
    var client: MockDropboxClient!
    var localCollection: SyncCollection!
    
    var completionHandler: SyncProcessCompletionHandler!
    
    func setup() {
        // defaults
        client = client ?? MockDropboxClient()
        localCollection = localCollection ?? TestingSyncCollection()
        completionHandler = completionHandler ?? { _ in }
        
        describedInstance = SyncProcess(client: client,
                                        localCollection: localCollection)
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
                
            }
            
            it("downloads the meta files") {
                
            }
            
            it("performs a sync") {
                
            }
            
            it("persists the sync status") {
                
            }
        }
    }
}
