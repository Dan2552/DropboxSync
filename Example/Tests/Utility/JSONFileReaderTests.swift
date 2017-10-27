@testable import DropboxSync
import Quick
import Nimble
import SwiftyJSON

class JSONFileReaderSpec: QuickSpec {
    var url: URL?

    override func spec() {
        describe("#read(:)") {
            func subject() -> SwiftyJSON.JSON? {
                return JSONFileReader().read(url!)
            }

            context("when the file contains valid json") {
                beforeEach {
                    self.url = mockMetaFile()
                }

                it("returns an object representing the json") {
                    expect(subject()!["type"]).to(equal("Note"))
                }
            }

            context("when the file does not exist") {
                beforeEach {
                    self.url = URL(string: "/fake/path.meta")
                }

                it("returns nil") {
                    expect(subject()).to(beNil())
                }
            }

            context("when the file contains invalid json") {
                beforeEach {
                    self.url = mockBrokenMetaFile()
                }

                it("returns nil") {
                    expect(subject()).to(beNil())
                }
            }
        }
    }
}
