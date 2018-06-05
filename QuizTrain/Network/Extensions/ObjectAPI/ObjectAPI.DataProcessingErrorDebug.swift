extension ObjectAPI.DataProcessingError: CustomDebugStringConvertible {

    public var debugDescription: String {
        var description = "ObjectAPI.DataProcessingError"
        switch self {
        case .couldNotConvertDataToJSON(_, _):
            description += ".couldNotConvertDataToJSON:\n\n\(debugDetails)\n"
        case .couldNotDeserializeFromJSON(_, _):
            description += ".couldNotDeserializeFromJSON:\n\n\(debugDetails)\n"
        case .invalidJSONFormat(_):
            description += ".invalidJSONFormat:\n\n\(debugDetails)\n"
        }
        return description
    }

}

extension ObjectAPI.DataProcessingError: DebugDetails {

    public var debugDetails: String {

        let details: String

        switch self {
        case .couldNotConvertDataToJSON(let data, let error):
            details = """
            _____DATA_____

            \(data)

            _____ERROR_____

            \(error)
            """
        case .couldNotDeserializeFromJSON(let objectType, let json):
            details = """
            _____DETAILS_____

            Object Type: \(objectType)

            _____JSON_____

            \(json)
            """
        case .invalidJSONFormat(let json):
            details = """
            _____JSON_____

            \(json)
            """
        }

        return details
    }

}
