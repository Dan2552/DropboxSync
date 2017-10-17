import SwiftyDropbox

class MockDropboxClient: DropboxClient {
    convenience init() {
        self.init(accessToken: "banana")
    }
}
