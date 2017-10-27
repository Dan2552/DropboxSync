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
                let collection = SyncCollection()
                collection.store.append(SyncElement(id: "one", updatedAt: Date()))
                collection.store.append(SyncElement(id: "two", updatedAt: Date()))
                describedInstance.write(collection)
            }

            it("writes to UserDefaults") {
                subject()
                expect(self.mockUserDefaults.setWasCalled).to(beTrue())
                expect(self.mockUserDefaults.setWasCalledValue).to(equal("one!~!~!~!two"))
            }
        }
    }
}
