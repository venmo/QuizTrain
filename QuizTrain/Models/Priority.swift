public struct Priority: Identifiable {
    public typealias Id = Int
    public let id: Id
    public let isDefault: Bool
    public let name: String
    public let priority: Int
    public let shortName: String
}

// MARK: - Equatable

extension Priority: Equatable {

    public static func==(lhs: Priority, rhs: Priority) -> Bool {
        return (lhs.id == rhs.id &&
            lhs.isDefault == rhs.isDefault &&
            lhs.name == rhs.name &&
            lhs.priority == rhs.priority &&
            lhs.shortName == rhs.shortName)
    }

}

// MARK: - JSON Keys

extension Priority {

    enum JSONKeys: JSONKey {
        case id
        case isDefault = "is_default"
        case name
        case priority
        case shortName = "short_name"
    }

}

// MARK: - Serialization

extension Priority: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let id = json[JSONKeys.id.rawValue] as? Id,
            let isDefault = json[JSONKeys.isDefault.rawValue] as? Bool,
            let name = json[JSONKeys.name.rawValue] as? String,
            let priority = json[JSONKeys.priority.rawValue] as? Int,
            let shortName = json[JSONKeys.shortName.rawValue] as? String else {
                return nil
        }

        self.init(id: id, isDefault: isDefault, name: name, priority: priority, shortName: shortName)
    }

}

extension Priority: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.id.rawValue: id,
                JSONKeys.isDefault.rawValue: isDefault,
                JSONKeys.name.rawValue: name,
                JSONKeys.priority.rawValue: priority,
                JSONKeys.shortName.rawValue: shortName]
    }

}
