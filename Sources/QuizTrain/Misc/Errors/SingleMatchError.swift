public enum SingleMatchError<QueryType>: Error {
    case noMatchFound(missing: QueryType)
}

extension SingleMatchError: CustomDebugStringConvertible {

    public var debugDescription: String {
        var description = "ObjectAPI.SingleMatchError"
        switch self {
        case .noMatchFound:
            description += ".noMatchFound:\n\n\(debugDetails)\n"
        }
        return description
    }

}

extension SingleMatchError: DebugDetails {

    public var debugDetails: String {
        let details: String
        switch self {
        case .noMatchFound:
            details = "No match was found."
        }
        return details
    }

}
