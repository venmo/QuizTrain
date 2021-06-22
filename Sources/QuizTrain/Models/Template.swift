public struct Template: Identifiable, Equatable {
    public typealias Id = Int
    public let isDefault: Bool
    public let id: Id
    public let name: String
}

// MARK: - JSON Keys

extension Template {

    enum JSONKeys: JSONKey {
        case isDefault = "is_default"
        case id
        case name
    }

}

// MARK: - Serialization

extension Template: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let isDefault = json[JSONKeys.isDefault.rawValue] as? Bool,
            let id = json[JSONKeys.id.rawValue] as? Id,
            let name = json[JSONKeys.name.rawValue] as? String else {
                return nil
        }

        self.init(isDefault: isDefault, id: id, name: name)
    }

}

extension Template: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.isDefault.rawValue: isDefault,
                JSONKeys.id.rawValue: id,
                JSONKeys.name.rawValue: name]
    }

}
