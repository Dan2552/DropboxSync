import SwiftyDropbox

class Dependency {
    static var listFiles: ()->(ListFiles) = {
        return ListFiles()
    }

    static var downloadFiles: ()->(DownloadFiles) = {
        return DownloadFiles()
    }

    static var uploadFile: ()->(UploadFile) = {
        return UploadFile()
    }

    static var syncCollection: ()->(SyncCollection) = {
        return SyncCollection()
    }

    static var sync: ()->(Sync) = {
        return Sync()
    }

    static var dropboxClient: ()->(DropboxClientProtocol) = {
        return DropboxClientsManager.authorizedClient!
    }

    static var statusPersistence: ()->(StatusPersistence) = {
        return StatusPersistence()
    }
}
