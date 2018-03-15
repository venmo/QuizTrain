public struct NewConfiguration {

    public var name: String

    public init(name: String) {
        self.name = name
    }

}

// MARK: - Equatable

extension NewConfiguration: Equatable {

    public static func==(lhs: NewConfiguration, rhs: NewConfiguration) -> Bool {
        return (lhs.name == rhs.name)
    }

}

// MARK: - JSON Keys

extension NewConfiguration {

    enum JSONKeys: JSONKey {
        case name
    }

}

extension NewConfiguration: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.name.rawValue]
    }

}

// MARK: - Serialization

extension NewConfiguration: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.name.rawValue: name]
    }

}

extension NewConfiguration: AddRequestJSON { }
