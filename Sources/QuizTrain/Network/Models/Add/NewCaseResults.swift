/*
 Use to bulk-add multiple results associated with Cases.
 */
public struct NewCaseResults: Equatable {

    public var results: [NewCaseResults.Result]

    public init(results: [NewCaseResults.Result]) {
        self.results = results
    }

}

// MARK: - Validatable

extension NewCaseResults: Validatable {

    var isValid: Bool {
        return (results.filter({ $0.isValid == false }).count == 0)
    }

}

// MARK: - JSON Keys

extension NewCaseResults {

    enum JSONKeys: JSONKey {
        case results
    }

}

extension NewCaseResults: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.results.rawValue]
    }

}

// MARK: - Serialization

extension NewCaseResults: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.results.rawValue: NewCaseResults.Result.serialized(results)]
    }

}

extension NewCaseResults: AddRequestJSON { }
