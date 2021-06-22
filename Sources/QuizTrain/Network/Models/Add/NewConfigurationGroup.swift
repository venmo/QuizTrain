public struct NewConfigurationGroup: Equatable {

    public var name: String

    public init(name: String) {
        self.name = name
    }

}

// MARK: - JSON Keys

extension NewConfigurationGroup {

    enum JSONKeys: JSONKey {
        case name
    }

}

extension NewConfigurationGroup: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.name.rawValue]
    }

}

// MARK: - Serialization

extension NewConfigurationGroup: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.name.rawValue: name]
    }

}

extension NewConfigurationGroup: AddRequestJSON { }
