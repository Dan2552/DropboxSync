@testable import DropboxSync
import Quick
import Nimble

class SyncSpec: QuickSpec {
    var describedInstance: Sync!
    var left: TestingSyncCollection!
    var right: TestingSyncCollection!
    var status: TestingSyncCollection!
    var conflictResolution: ConflictResolution!

    func setup() {
        // defaults
        left = left ?? TestingSyncCollection([])
        right = right ?? TestingSyncCollection([])
        status = status ?? TestingSyncCollection([])
        conflictResolution = conflictResolution ?? { lhs, rhs in return .lhs }
        
        self.describedInstance = Sync(left: self.left,
                                      right: self.right,
                                      status: self.status,
                                      conflictResolution: self.conflictResolution)
    }

    override func spec() {
        beforeEach {
            self.describedInstance = nil
            self.left = nil
            self.right = nil
            self.status = nil
            self.conflictResolution = nil
        }
        
        describe("#perform") {
            func subject() {
                setup()
                describedInstance.perform()
            }
            
            context("when an element is only on left") {
                beforeEach {
                    self.left = TestingSyncCollection(["a"])
                }
                
                it("is copied") {
                    subject()
                    expect(self.left.ids).to(contain("a"))
                    expect(self.right.ids).to(contain("a"))
                    expect(self.status.ids).to(contain("a"))
                }
            }
            
            context("when an element is only on right") {
                beforeEach {
                    self.right = TestingSyncCollection(["a"])
                }
                
                it("is copied") {
                    subject()
                    expect(self.left.ids).to(contain("a"))
                    expect(self.right.ids).to(contain("a"))
                    expect(self.status.ids).to(contain("a"))
                }
            }
            
            context("when an element is on left and status") {
                beforeEach {
                    self.left = TestingSyncCollection(["a", "b"])
                    self.status = TestingSyncCollection(["a", "c"])
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
                    self.right = TestingSyncCollection(["a"])
                    self.status = TestingSyncCollection(["a"])
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
                    self.status = TestingSyncCollection(["a"])
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
                    self.left = TestingSyncCollection(["a"])
                    self.left.store.first!.meta = "originates from left"
                    self.right = TestingSyncCollection(["a"])
                    self.right.store.first!.meta = "originates from right"
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
                        
                        expect(self.left.store.first!.meta)
                            .to(equal("originates from left"))
                        expect(self.right.store.first!.meta)
                            .to(equal("originates from left"))
                        expect(self.status.store.first!.meta)
                            .to(equal("originates from left"))
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
                        
                        expect(self.left.store.first!.meta)
                            .to(equal("originates from right"))
                        expect(self.right.store.first!.meta)
                            .to(equal("originates from right"))
                        expect(self.status.store.first!.meta)
                            .to(equal("originates from right"))
                    }
                }
            }
            
            context("when an element is on left and right and status") {
                beforeEach {
                    self.left = TestingSyncCollection(["a"])
                    self.left.store.first!.meta = "originates from left"
                    self.right = TestingSyncCollection(["a"])
                    self.right.store.first!.meta = "originates from right"
                    self.status = TestingSyncCollection(["a"])
                    self.status.store.first!.meta = "originates from status"
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
                        
                        expect(self.left.store.first!.meta)
                            .to(equal("originates from left"))
                        expect(self.right.store.first!.meta)
                            .to(equal("originates from left"))
                        expect(self.status.store.first!.meta)
                            .to(equal("originates from left"))
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
                        
                        expect(self.left.store.first!.meta)
                            .to(equal("originates from right"))
                        expect(self.right.store.first!.meta)
                            .to(equal("originates from right"))
                        expect(self.status.store.first!.meta)
                            .to(equal("originates from right"))
                    }
                }
            }
        }
    }
}

