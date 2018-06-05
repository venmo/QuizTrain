extension ObjectAPI.ObjectConversionError: CustomDebugStringConvertible {

    public var debugDescription: String {
        var description = "ObjectAPI.ObjectConversionError"
        switch self {
        case .couldNotConvertObjectToData(_, _, _):
            description += ".couldNotConvertObjectToData:\n\n\(debugDetails)\n"
        case .couldNotConvertObjectsToData(_, _, _):
            description += ".couldNotConvertObjectsToData:\n\n\(debugDetails)\n"
        }
        return description
    }

}

extension ObjectAPI.ObjectConversionError: DebugDetails {

    public var debugDetails: String {

        let details: String

        switch self {
        case .couldNotConvertObjectToData(let object, let json, let error):
            details = """
            _____OBJECT_____

            \(object)

            _____JSON_____

            \(json)

            _____ERROR_____

            \(error)
            """
        case .couldNotConvertObjectsToData(let objects, let json, let error):
            details = """
            _____OBJECTS_____

            \(objects)

            _____JSON_____

            \(json)

            _____ERROR_____

            \(error)
            """
        }

        return details
    }

}
