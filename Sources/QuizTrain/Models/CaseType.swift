public struct CaseType: Identifiable, Equatable {
    public typealias Id = Int
    public let id: Id
    public let isDefault: Bool
    public let name: String
}

// MARK: - JSON Keys

extension CaseType {

    enum JSONKeys: JSONKey {
        case id
        case isDefault = "is_default"
        case name
    }

}

// MARK: - Serialization

extension CaseType: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let id = json[JSONKeys.id.rawValue] as? Id,
            let isDefault = json[JSONKeys.isDefault.rawValue] as? Bool,
            let name = json[JSONKeys.name.rawValue] as? String else {
                return nil
        }

        self.init(id: id, isDefault: isDefault, name: name)
    }

}

extension CaseType: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.id.rawValue: id,
                JSONKeys.isDefault.rawValue: isDefault,
                JSONKeys.name.rawValue: name]
    }

}
