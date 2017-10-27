import SwiftyJSON

class RemotePersistence {
    private let uploadGroup = DispatchGroup()

    var uploadFile = UploadFile()

    init() {

    }

    func persist(element: SyncElement) {
        let uuid = element.id
        let contentPath = "/\(uuid)/content.json"
        let metaPath = "/\(uuid)/meta.json"

        let data = syncable.syncableSerialize()

        buildMeta()
        uploadContent()
        uploadMeta()

        uploadGroup.notify(queue: DispatchQueue.main) {
            self.next(.upload)
        }
    }

    private func buildMeta() {
        let meta = [
            "uuid": uuid,
            "updated_at": Int(element.updatedAt.timeIntervalSince1970),
            "type": "\(syncableType)" // TODO: needed?
        ] as [String : Any]
        let metaData = try! SwiftyJSON.JSON(meta).rawData()
    }

    private func uploadMeta() {
        uploadGroup.enter()

        self.client.files.upload(path: metaPath, mode: Files.WriteMode.overwrite, input: metaData).response { response, error in
            if let metadata = response {
                log("Uploaded file name: \(metadata.name) - \(metaPath)")
            } else {
                print(error!)
            }
            uploadGroup.leave()
        }
    }

    private func uploadContent() {
        uploadGroup.enter()

        self.client.files.upload(path: contentPath, mode: Files.WriteMode.overwrite, input: data).response { response, error in
            if let metadata = response {
                log("Uploaded file name: \(metadata.name) - \(contentPath)")
            } else {
                print(error!)
            }
            uploadGroup.leave()
        }
    }
}
