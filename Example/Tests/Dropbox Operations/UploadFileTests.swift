@testable import DropboxSync
import Quick
import Nimble

class UploadFileSpec: QuickSpec {
    var describedInstance = UploadFile()

    var mocks: Mocks!

    func setup() {
        Dependency.dropboxClient = { return self.mocks.dropboxClient }

        mocks = mocks ?? Mocks()
    }

    override func spec() {
        beforeEach {
            self.mocks = nil
            self.setup()
        }

        describe("#perform(remotePath:data:completion:)") {
            let remotePath = "/remote/path"
            let data = Data()
            var didComplete = false
            var completionResult: Bool!

            func subject() {
                describedInstance.perform(remotePath: remotePath, data: data) { result in
                    didComplete = true
                    completionResult = result
                }
            }

            it("uploads to Dropbox") {
                subject()
                expect(self.mocks.dropboxClient.filesMock.didUpload).to(beTrue())
            }

            context("when uploading is successful") {
                beforeEach {
                    self.mocks.dropboxClient.filesMock.shouldSucceed = true
                }

                it("calls the completion handler with true") {
                    subject()
                    expect(completionResult).to(beTrue())
                }
            }

            context("when uploading is unsuccessful") {
                beforeEach {
                    self.mocks.dropboxClient.filesMock.shouldSucceed = false
                }

                it("calls the completion handler with false") {
                    subject()
                    expect(completionResult).to(beFalse())
                }
            }
        }
    }
}
