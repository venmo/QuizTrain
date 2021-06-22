extension ObjectAPI.UpdateRequestError: CustomDebugStringConvertible {

    public var debugDescription: String {
        var description = "ObjectAPI.UpdateRequestError"
        switch self {
        case .apiError(_):
            description += ".apiError:\n\n\(debugDetails)\n"
        case .dataProcessingError(_):
            description += ".dataProcessingError:\n\n\(debugDetails)\n"
        case .objectConversionError(_):
            description += ".objectConversionError:\n\n\(debugDetails)\n"
        case .statusCodeError(_):
            description += ".statusCodeError:\n\n\(debugDetails)\n"
        }
        return description
    }

}

extension ObjectAPI.UpdateRequestError: DebugDetails {

    public var debugDetails: String {
        let details: String
        switch self {
        case .apiError(let error):
            details = error.debugDetails
        case .dataProcessingError(let error):
            details = error.debugDetails
        case .objectConversionError(error: let error):
            details = error.debugDetails
        case .statusCodeError(let error):
            details = error.debugDetails
        }
        return details
    }

}
