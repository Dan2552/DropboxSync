@testable import SwiftyDropbox
@testable import DropboxSync

class DropboxClientMock: DropboxClientProtocol {
    let filesMock = MockFilesRoutes()

    var files: FilesRoutes! {
        return filesMock
    }
}

class MockFilesRoutes: FilesRoutes {
    var shouldSucceed = true
    var didListFolder = false
    var didUpload = false

    convenience init() {
        self.init(client: DropboxTransportClient(accessToken: "banana"))
    }

    override func upload(path: String, mode: Files.WriteMode, autorename: Bool, clientModified: Date?, mute: Bool, input: Data) -> UploadRequest<Files.FileMetadataSerializer, Files.UploadErrorSerializer> {

        didUpload = true

        return super.upload(path: path, mode: mode, autorename: autorename, clientModified: clientModified, mute: mute, input: input)
    }

    override func listFolder(path: String, recursive: Bool, includeMediaInfo: Bool, includeDeleted: Bool, includeHasExplicitSharedMembers: Bool) -> RpcRequest<Files.ListFolderResultSerializer, Files.ListFolderErrorSerializer> {

        didListFolder = true

        return super.listFolder(path: path, recursive: recursive, includeMediaInfo: includeMediaInfo, includeDeleted: includeDeleted, includeHasExplicitSharedMembers: includeHasExplicitSharedMembers)
    }
}
