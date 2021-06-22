extension API.RequestResult: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "API.RequestResult:\n\n\(debugDetails)\n"
    }

}

extension API.RequestResult: DebugDetails {

    public var debugDetails: String {
        return """
        _____REQUEST_____

        \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")

        \(request.httpHeaderFieldsAsMultiLineString(omittingHeaders: ["AUTHORIZATION"]) ?? "")

        \(request.httpBodyAsUTF8 ?? "")

        _____RESPONSE_____

        \(response)

        \(String(data: data, encoding: .utf8) ?? "")
        """
    }

}
