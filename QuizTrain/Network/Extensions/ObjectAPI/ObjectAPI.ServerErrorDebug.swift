extension ObjectAPI.ServerError: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "ObjectAPI.ServerError:\n\n\(debugDetails)\n"
    }

}

extension ObjectAPI.ServerError: DebugDetails {

    public var debugDetails: String {
        return """
        _____DETAILS_____

        CODE: \(statusCode)

        MESSAGE: \(message)

        \(requestResult.debugDetails)
        """
    }

}
