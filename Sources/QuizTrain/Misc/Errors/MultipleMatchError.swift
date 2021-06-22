public enum MultipleMatchError<MatchType, QueryType: Hashable>: Error {
    case noMatchesFound(missing: Set<QueryType>)
    case partialMatchesFound(matches: [MatchType], missing: Set<QueryType>)
}

extension MultipleMatchError: CustomDebugStringConvertible {

    public var debugDescription: String {
        var description = "ObjectAPI.MultipleMatchError"
        switch self {
        case .noMatchesFound:
            description += ".noMatchesFound:\n\n\(debugDetails)\n"
        case .partialMatchesFound(_):
            description += ".partialMatchesFound:\n\n\(debugDetails)\n"
        }
        return description
    }

}

extension MultipleMatchError: DebugDetails {

    public var debugDetails: String {
        let details: String
        switch self {
        case .noMatchesFound:
            details = "Zero matches were found."
        case .partialMatchesFound(let matches):
            details = "\(matches)"
        }
        return details
    }

}
