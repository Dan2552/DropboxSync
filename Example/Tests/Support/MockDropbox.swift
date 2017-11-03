@testable import SwiftyDropbox
@testable import DropboxSync

class DropboxClientMock: DropboxClientProtocol {
    var files: FilesRoutes! {
        return MockFilesRoutes()
    }
}

class MockFilesRoutes: FilesRoutes {
    var didListFolder: Bool = false

    convenience init() {
        self.init(client: DropboxTransportClient(accessToken: "banana"))
    }

    override func listFolder(path: String, recursive: Bool, includeMediaInfo: Bool, includeDeleted: Bool, includeHasExplicitSharedMembers: Bool) -> RpcRequest<Files.ListFolderResultSerializer, Files.ListFolderErrorSerializer> {
        didListFolder = true

        return super.listFolder(path: path, recursive: recursive, includeMediaInfo: includeMediaInfo, includeDeleted: includeDeleted, includeHasExplicitSharedMembers: includeHasExplicitSharedMembers)
    }
}
