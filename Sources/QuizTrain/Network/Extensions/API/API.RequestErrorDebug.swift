extension API.RequestError: CustomDebugStringConvertible {

    public var debugDescription: String {

        var description: String = "API.RequestError"

        switch self {
        case .error(_, _):
            description += ".error:\n\n\(debugDetails)\n"
        case .invalidResponse(_, _):
            description += ".invalidResponse:\n\n\(debugDetails)\n"
        case .nilResponse(_):
            description += ".nilResponse:\n\n\(debugDetails)\n"
        }

        return description
    }

}

extension API.RequestError: DebugDetails {

    public var debugDetails: String {

        let details: String

        switch self {
        case .error(let request, let error):
            details = """
            _____ERROR_____

            \(error)

            _____REQUEST_____

            \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")

            \(request.httpHeaderFieldsAsMultiLineString(omittingHeaders: ["AUTHORIZATION"]) ?? "")

            \(request.httpBodyAsUTF8 ?? "")
            """
        case .invalidResponse(let request, let response):
            details = """
            _____REQUEST_____

            \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")

            \(request.httpHeaderFieldsAsMultiLineString(omittingHeaders: ["AUTHORIZATION"]) ?? "")

            \(request.httpBodyAsUTF8 ?? "")

            _____RESPONSE_____

            \(response)
            """
        case .nilResponse(let request):
            details = """
            _____REQUEST_____

            \(request.httpMethod ?? "") \(request.url?.absoluteString ?? "")

            \(request.httpHeaderFieldsAsMultiLineString(omittingHeaders: ["AUTHORIZATION"]) ?? "")

            \(request.httpBodyAsUTF8 ?? "")
            """
        }

        return details
    }

}
