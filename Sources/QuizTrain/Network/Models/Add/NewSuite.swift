public struct NewSuite: Equatable {

    public var description: String?
    public var name: String

    public init(description: String? = nil, name: String) {
        self.description = description
        self.name = name
    }

}

// MARK: - JSON Keys

extension NewSuite {

    enum JSONKeys: JSONKey {
        case description
        case name
    }

}

extension NewSuite: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.description.rawValue,
                JSONKeys.name.rawValue]
    }

}

// MARK: - Serialization

extension NewSuite: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.description.rawValue: description as Any,
                JSONKeys.name.rawValue: name]
    }

}

extension NewSuite: AddRequestJSON { }
