public struct NewConfiguration: Equatable {

    public var name: String

    public init(name: String) {
        self.name = name
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
