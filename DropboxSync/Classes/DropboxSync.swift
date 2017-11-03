

// public class DSync {


//     public init(serialize: @escaping SyncSerialize, deserialize: @escaping SyncDeserialize, collection: [SyncElement]) {
//         self.serialize = serialize
//         self.deserialize = deserialize
//         self.collection = collection
//     }

//     public func perform() {
//         let process = SyncProcess.init(localCollection: buildCollection())
//         process.perform()
//     }

//     private func buildCollection() -> SyncCollection {
//         let sc = SyncCollection()
//         sc.store = collection
//         return sc
//     }
// }
