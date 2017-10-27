@testable import DropboxSync
import Quick
import Nimble

class LoggingSpec: QuickSpec {
    let string = "hello world"

    override func spec() {
        describe("#log(:)") {
            func subject() {
                log(string)
            }

            context("when verbose is enabled on options") {
                beforeEach {
                    Options.verbose = true
                }

                it("prints to the console") {
                    // No idea how to assert this in Swift
                }
            }

            context("when verbose is disabled on options") {
                beforeEach {
                    Options.verbose = false
                }

                it("does not print to the console") {
                    // No idea how to assert this in Swift
                }
            }
        }
    }
}
