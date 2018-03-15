/*
 Use to bulk-add multiple results associated with Tests.
 */
public struct NewTestResults {

    public var results: [NewTestResults.Result]

    public init(results: [NewTestResults.Result]) {
        self.results = results
    }

}

// MARK: - Equatable

extension NewTestResults: Equatable {

    public static func==(lhs: NewTestResults, rhs: NewTestResults) -> Bool {
        return (lhs.results.contentsAreEqual(to: rhs.results))
    }

}

// MARK: - Validatable

extension NewTestResults: Validatable {

    var isValid: Bool {
        return (results.filter({ $0.isValid == false }).count == 0)
    }

}

// MARK: - JSON Keys

extension NewTestResults {

    enum JSONKeys: JSONKey {
        case results
    }

}

extension NewTestResults: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.results.rawValue]
    }

}

// MARK: - Serialization

extension NewTestResults: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.results.rawValue: NewTestResults.Result.serialized(results)]
    }

}

extension NewTestResults: AddRequestJSON { }
