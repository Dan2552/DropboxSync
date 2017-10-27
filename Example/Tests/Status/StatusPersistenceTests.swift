@testable import DropboxSync
import Quick
import Nimble

class StatusPersistenceSpec: QuickSpec {
    var describedInstance = StatusPersistence()
    var mockUserDefaults = UserDefaultsMock()
    override func spec() {
        beforeEach {
            self.mockUserDefaults = UserDefaultsMock()
            self.describedInstance = StatusPersistence()
            self.describedInstance.defaults = self.mockUserDefaults
        }

        describe("#read") {
            func subject() -> SyncCollection {
                return describedInstance.read()
            }

            it("reads from UserDefaults") {
                _ = subject()
                expect(self.mockUserDefaults.objectWasCalled).to(beTrue())
            }

            it("returns a list of ids") {
                let ids = subject().ids
                expect(ids).to(contain("1"))
                expect(ids).to(contain("2"))
                expect(ids).to(contain("3"))
            }
        }

        describe("#write(:)") {
            func subject() {
                describedInstance.write(SyncCollection())
            }

            it("writes to UserDefaults") {
                subject()
                expect(self.mockUserDefaults.setWasCalled).to(beTrue())
            }
        }
    }
}
