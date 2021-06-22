public struct User: Identifiable, Equatable {
    public typealias Id = Int
    public let email: String
    public let id: Id
    public let isActive: Bool
    public let name: String
}

// MARK: - JSON Keys

extension User {

    enum JSONKeys: JSONKey {
        case email
        case id
        case isActive = "is_active"
        case name
    }

}

// MARK: - Serialization

extension User: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let email = json[JSONKeys.email.rawValue] as? String,
            let id = json[JSONKeys.id.rawValue] as? Id,
            let isActive = json[JSONKeys.isActive.rawValue] as? Bool,
            let name = json[JSONKeys.name.rawValue] as? String else {
                return nil
        }

        self.init(email: email, id: id, isActive: isActive, name: name)
    }

}

extension User: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.email.rawValue: email,
                JSONKeys.id.rawValue: id,
                JSONKeys.isActive.rawValue: isActive,
                JSONKeys.name.rawValue: name]
    }

}
