extension ObjectAPI.MatchError: DebugDescription {

    var debugDescription: String {
        var description = "ObjectAPI.MatchError"
        switch self {
        case .matchError(_):
            description += ".matchError:\n\n\(debugDetails)\n"
        case .otherError(_):
            description += ".otherError:\n\n\(debugDetails)\n"
        }
        return description
    }

}

extension ObjectAPI.MatchError where MatchErrorType: DebugDescription, OtherErrorType: DebugDescription {

    var debugDescription: String {
        var description = "ObjectAPI.MatchError"
        switch self {
        case .matchError(let error):
            description += ".matchError: \(error.debugDescription)\n"
        case .otherError(let error):
            description += ".otherError: \(error.debugDescription)\n"
        }
        return description
    }

}

extension ObjectAPI.MatchError: DebugDetails {

    var debugDetails: String {
        let details: String
        switch self {
        case .matchError(let error):
            details = "\(error)"
        case .otherError(let error):
            details = "\(error)"
        }
        return details
    }

}

extension ObjectAPI.MatchError where MatchErrorType: DebugDetails, OtherErrorType: DebugDetails {

    var debugDetails: String {
        let details: String
        switch self {
        case .matchError(let error):
            details = "\(error.debugDetails)"
        case .otherError(let error):
            details = "\(error.debugDetails)"
        }
        return details
    }

}
