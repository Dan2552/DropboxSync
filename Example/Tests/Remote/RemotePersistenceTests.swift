@testable import DropboxSync
import Quick
import Nimble

class RemotePersistenceSpec: QuickSpec {
    var describedInstance = RemotePersistence()
    var didComplete = false

    var mocks: Mocks!

    func setup() {
        Dependency.uploadFile = { return self.mocks.uploadFile }

        mocks = mocks ?? Mocks()
    }

    override func spec() {
        beforeEach {
            self.mocks = nil
            self.setup()
        }

        describe("#persist(element:completion:)") {
            it("uploads metadata") {

            }

            it("uploads content") {

            }
        }
    }
}
