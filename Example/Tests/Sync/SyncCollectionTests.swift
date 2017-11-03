@testable import DropboxSync
import Quick
import Nimble

class SyncCollectionSpec: QuickSpec {
    var describedInstance = SyncCollection()

    override func spec() {
        beforeEach {
            self.describedInstance = SyncCollection()
        }

        describe("#ids") {
            func subject() -> [String] {
                return describedInstance.ids
            }

            context("when there are elements in the store") {
                beforeEach {
                    self.describedInstance.store = []
                    let element1 = SyncElement(id: "one", type: "test", updatedAt: Date())
                    let element2 = SyncElement(id: "two", type: "test", updatedAt: Date())
                    self.describedInstance.store.append(element1)
                    self.describedInstance.store.append(element2)
                }

                it("returns the ids of the elements") {
                    expect(subject()).to(contain("one"))
                    expect(subject()).to(contain("two"))
                }
            }

            context("when there are no elements in the store") {
                beforeEach {
                    self.describedInstance.store = []
                }
                it("returns an empty array") {
                    expect(subject()).to(beEmpty())
                }
            }
        }

        describe("#commitChanges(completion:)") {
            func subject() {
                describedInstance.commitChanges {}
            }

            context("without subclassing") {
                it("raises an error") {
                    expect { subject() }.to(throwAssertion())
                }
            }
        }

        describe("#contains(id:)") {
            func subject() -> Bool {
                return describedInstance.contains(id: "one")
            }

            context("when there is an element with the id in the store") {
                beforeEach {
                    self.describedInstance.store = []
                    let element1 = SyncElement(id: "one", type: "test", updatedAt: Date())
                    self.describedInstance.store.append(element1)
                }

                it("returns true") {
                    expect(subject()).to(beTrue())
                }
            }

            context("when there is not an element with the id in the store") {
                beforeEach {
                    self.describedInstance.store = []
                    let element2 = SyncElement(id: "two", type: "test", updatedAt: Date())
                    self.describedInstance.store.append(element2)
                }

                it("returns false") {
                    expect(subject()).to(beFalse())
                }
            }
        }
    }
}
