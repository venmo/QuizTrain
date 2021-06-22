extension ObjectAPI.RequestError: CustomDebugStringConvertible {

    public var debugDescription: String {
        var description = "ObjectAPI.RequestError"
        switch self {
        case .apiError(_):
            description += ".apiError:\n\n\(debugDetails)\n"
        case .statusCodeError(_):
            description += ".statusCodeError:\n\n\(debugDetails)\n"
        }
        return description
    }

}

extension ObjectAPI.RequestError: DebugDetails {

    public var debugDetails: String {
        let details: String
        switch self {
        case .apiError(let error):
            details = error.debugDetails
        case .statusCodeError(let error):
            details = error.debugDetails
        }
        return details
    }

}
