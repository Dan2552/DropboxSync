import SwiftyJSON

typealias RemotePersistanceCompletionHandler = ()->()

class RemotePersistence {
    var uploadFile = UploadFile()
    private let uploadGroup = DispatchGroup()
    private var element: SyncElement!
    
    private var uuid: String {
        return element.id
    }
    
    private var contentPath: String {
        return "/\(uuid)/content.json"
    }
    
    private var metaPath: String {
        return "/\(uuid)/meta.json"
    }
    
    init() {

    }

    func persist(element: SyncElement, completion: @escaping RemotePersistanceCompletionHandler) {
//        self.element = element
//
//        let data = syncable.syncableSerialize()
//
//        buildMeta()
//        uploadContent()
//        uploadMeta()
//
//        uploadGroup.notify(queue: DispatchQueue.main) {
//            completion()
//        }
    }

    private func buildMeta() {
//        let meta = [
//            "uuid": uuid,
//            "updated_at": Int(element.updatedAt.timeIntervalSince1970),
//            "type": "\(syncableType)" // TODO: needed?
//        ] as [String : Any]
//        let metaData = try! SwiftyJSON.JSON(meta).rawData()
    }

    private func uploadMeta() {
//        uploadGroup.enter()
//
//        self.client.files.upload(path: metaPath, mode: Files.WriteMode.overwrite, input: metaData).response { response, error in
//            if let metadata = response {
//                log("Uploaded file name: \(metadata.name) - \(metaPath)")
//            } else {
//                print(error!)
//            }
//            uploadGroup.leave()
//        }
    }

    private func uploadContent() {
//        uploadGroup.enter()
//
//        self.client.files.upload(path: contentPath, mode: Files.WriteMode.overwrite, input: data).response { response, error in
//            if let metadata = response {
//                log("Uploaded file name: \(metadata.name) - \(contentPath)")
//            } else {
//                print(error!)
//            }
//            uploadGroup.leave()
//        }
    }
}
