public struct NewSuite {

    public var description: String?
    public var name: String

    public init(description: String? = nil, name: String) {
        self.description = description
        self.name = name
    }

}

// MARK: - Equatable

extension NewSuite: Equatable {

    public static func==(lhs: NewSuite, rhs: NewSuite) -> Bool {
        return (lhs.description == rhs.description &&
            lhs.name == rhs.name)
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
