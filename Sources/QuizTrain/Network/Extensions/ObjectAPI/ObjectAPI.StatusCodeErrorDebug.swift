extension ObjectAPI.StatusCodeError: CustomDebugStringConvertible {

    public var debugDescription: String {
        var description = "ObjectAPI.StatusCodeError"
        switch self {
        case .clientError(_):
            description += ".clientError:\n\n\(debugDetails)\n"
        case .otherError(_):
            description += ".otherError:\n\n\(debugDetails)\n"
        case .serverError(_):
            description += ".serverError:\n\n\(debugDetails)\n"
        }
        return description
    }

}

extension ObjectAPI.StatusCodeError: DebugDetails {

    public var debugDetails: String {
        let details: String
        switch self {
        case .clientError(let clientError):
            details = clientError.debugDetails
        case .otherError(let requestResult):
            details = requestResult.debugDetails
        case .serverError(let serverError):
            details = serverError.debugDetails
        }
        return details
    }

}
