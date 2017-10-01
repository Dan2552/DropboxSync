enum ConflictResolutionResult {
    case lhs
    case rhs
}

typealias ConflictResolution = (_ lhs: SyncElement, _ rhs: SyncElement) -> ConflictResolutionResult
