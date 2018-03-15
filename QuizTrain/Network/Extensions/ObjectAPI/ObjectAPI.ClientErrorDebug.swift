extension ObjectAPI.ClientError: DebugDescription {

    public var debugDescription: String {
        return "ObjectAPI.ClientError:\n\n\(debugDetails)\n"
    }

}

extension ObjectAPI.ClientError: DebugDetails {

    public var debugDetails: String {
        return """
        _____DETAILS_____

        CODE: \(statusCode)

        MESSAGE: \(message)

        \(requestResult.debugDetails)
        """
    }

}
