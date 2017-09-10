fileprivate let defaults = UserDefaults.standard

/// By persisting the IDs of the previous sync, we know
/// which IDs have been deleted locally since then
func persistPreviousSync(type: DropboxSyncable.Type, ids: [String]) {
    let str = ids.joined(separator: "~~~")
    
    defaults.set(str, forKey: "DropboxSyncPreviousSync_\(type)")
}

func fetchPreviousSync(type: DropboxSyncable.Type) -> [String] {
    let str = defaults.object(forKey: "DropboxSyncPreviousSync_\(type)")
        as? String
        ?? ""
    
    return str.components(separatedBy: "~~~")
}
