@testable import DropboxSync
import Quick
import Nimble

class SyncSpec: QuickSpec {
    var describedInstance: Sync!
    var left: SyncCollectionMock!
    var right: SyncCollectionMock!
    var status: SyncCollectionMock!
    var conflictResolution: ConflictResolution!

    func setup() {
        left = left ?? SyncCollectionMock()
        right = right ?? SyncCollectionMock()
        status = status ?? SyncCollectionMock()
        conflictResolution = conflictResolution ?? { lhs, rhs in return .lhs }

        describedInstance = describedInstance ?? Sync()
        describedInstance.l = self.left
        describedInstance.r = self.right
        describedInstance.s = self.status
        describedInstance.conflictResolution = self.conflictResolution
    }

    override func spec() {
        beforeEach {
            self.describedInstance = nil
            self.left = nil
            self.right = nil
            self.status = nil
            self.conflictResolution = nil
            self.setup()
        }

        describe("#perform") {
            func subject() {
                setup()
                describedInstance.perform { _ in
// TODO: test callback
                }
            }

            context("when an element is only on left") {
                beforeEach {
                    self.left.store.append(SyncElement(id: "left", updatedAt: Date()))
                }

                it("is copied") {
                    subject()
                    expect(self.left.ids).to(contain("left"))
                    expect(self.right.ids).to(contain("left"))
                    expect(self.status.ids).to(contain("left"))
                }
            }

            context("when an element is only on right") {
                beforeEach {
                    self.right.store.append(SyncElement(id: "right", updatedAt: Date()))
                }

                it("is copied") {
                    subject()
                    expect(self.left.ids).to(contain("right"))
                    expect(self.right.ids).to(contain("right"))
                    expect(self.status.ids).to(contain("right"))
                }
            }

            context("when an element is on left and status") {
                beforeEach {
                    self.left.store.append(SyncElement(id: "a", updatedAt: Date()))
                    self.status.store.append(SyncElement(id: "a", updatedAt: Date()))
                }

                it("is deleted") {
                    subject()
                    expect(self.left.ids).toNot(contain("a"))
                    expect(self.right.ids).toNot(contain("a"))
                    expect(self.status.ids).toNot(contain("a"))
                }
            }

            context("when an element is on right and status") {
                beforeEach {
                    self.right.store.append(SyncElement(id: "a", updatedAt: Date()))
                    self.status.store.append(SyncElement(id: "a", updatedAt: Date()))
                }

                it("is deleted") {
                    subject()
                    expect(self.left.ids).toNot(contain("a"))
                    expect(self.right.ids).toNot(contain("a"))
                    expect(self.status.ids).toNot(contain("a"))
                }
            }

            context("when an element is on status") {
                beforeEach {
                    self.status.store.append(SyncElement(id: "a", updatedAt: Date()))
                }

                it("is deleted") {
                    subject()
                    expect(self.left.ids).toNot(contain("a"))
                    expect(self.right.ids).toNot(contain("a"))
                    expect(self.status.ids).toNot(contain("a"))
                }
            }

            context("when an element is on left and right") {
                beforeEach {
                    let fromLeft = SyncElementMock(id: "a", updatedAt: Date())
                    let fromRight = SyncElementMock(id: "a", updatedAt: Date())
                    fromLeft.meta = "originates from left"
                    fromRight.meta = "originates from right"
                    self.left.store.append(fromLeft)
                    self.right.store.append(fromRight)
                }

                context("when conflict resolution chooses left") {
                    beforeEach {
                        self.conflictResolution = { lhs, rhs in
                            return .lhs
                        }
                    }

                    it("syncs from left") {
                        subject()
                        expect(self.left.ids).to(contain("a"))
                        expect(self.right.ids).to(contain("a"))
                        expect(self.status.ids).to(contain("a"))

                        let leftFirst = self.left.store.first! as! SyncElementMock
                        let rightFirst = self.right.store.first! as! SyncElementMock
                        let statusFirst = self.status.store.first! as! SyncElementMock

                        expect(leftFirst.meta).to(equal("originates from left"))
                        expect(rightFirst.meta).to(equal("originates from left"))
                        expect(statusFirst.meta).to(equal("originates from left"))
                    }
                }

                context("when conflict resolution chooses right") {
                    beforeEach {
                        self.conflictResolution = { lhs, rhs in
                            return .rhs
                        }
                    }

                    it("syncs from right") {
                        subject()
                        expect(self.left.ids).to(contain("a"))
                        expect(self.right.ids).to(contain("a"))
                        expect(self.status.ids).to(contain("a"))

                        let leftFirst = self.left.store.first! as! SyncElementMock
                        let rightFirst = self.right.store.first! as! SyncElementMock
                        let statusFirst = self.status.store.first! as! SyncElementMock

                        expect(leftFirst.meta).to(equal("originates from right"))
                        expect(rightFirst.meta).to(equal("originates from right"))
                        expect(statusFirst.meta).to(equal("originates from right"))
                    }
                }
            }

            context("when an element is on left and right and status") {
                beforeEach {
                    let fromLeft = SyncElementMock(id: "a", updatedAt: Date())
                    let fromRight = SyncElementMock(id: "a", updatedAt: Date())
                    let fromStatus = SyncElementMock(id: "a", updatedAt: Date())
                    fromLeft.meta = "originates from left"
                    fromRight.meta = "originates from right"
                    fromStatus.meta = "originates from status"
                    self.left.store.append(fromLeft)
                    self.right.store.append(fromRight)
                    self.status.store.append(fromStatus)
                }

                context("when conflict resolution chooses left") {
                    beforeEach {
                        self.conflictResolution = { lhs, rhs in
                            return .lhs
                        }
                    }

                    it("syncs from left") {
                        subject()
                        expect(self.left.ids).to(contain("a"))
                        expect(self.right.ids).to(contain("a"))
                        expect(self.status.ids).to(contain("a"))

                        let leftFirst = self.left.store.first! as! SyncElementMock
                        let rightFirst = self.right.store.first! as! SyncElementMock
                        let statusFirst = self.status.store.first! as! SyncElementMock

                        expect(leftFirst.meta).to(equal("originates from left"))
                        expect(rightFirst.meta).to(equal("originates from left"))
                        expect(statusFirst.meta).to(equal("originates from left"))
                    }
                }

                context("when conflict resolution chooses right") {
                    beforeEach {
                        self.conflictResolution = { lhs, rhs in
                            return .rhs
                        }
                    }

                    it("syncs from right") {
                        subject()
                        expect(self.left.ids).to(contain("a"))
                        expect(self.right.ids).to(contain("a"))
                        expect(self.status.ids).to(contain("a"))

                        let leftFirst = self.left.store.first! as! SyncElementMock
                        let rightFirst = self.right.store.first! as! SyncElementMock
                        let statusFirst = self.status.store.first! as! SyncElementMock

                        expect(leftFirst.meta).to(equal("originates from right"))
                        expect(rightFirst.meta).to(equal("originates from right"))
                        expect(statusFirst.meta).to(equal("originates from right"))
                    }
                }
            }
        }
    }
}

