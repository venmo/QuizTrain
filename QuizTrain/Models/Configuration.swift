public struct Configuration: Identifiable {
    public typealias Id = Int
    public let id: Id
    public let groupId: ConfigurationGroup.Id
    public var name: String
}

// MARK: - Foward Relationships (ObjectAPI)

extension Configuration {

    public func configurationGroup(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<ConfigurationGroup, ObjectAPI.MatchError<SingleMatchError<Configuration.Id>, ErrorContainer<ObjectAPI.GetError>>>) -> Void) {
        objectAPI.configurationGroup(self, completionHandler: completionHandler)
    }

}

// MARK: - Equatable

extension Configuration: Equatable {

    public static func==(lhs: Configuration, rhs: Configuration) -> Bool {
        return (lhs.id == rhs.id &&
            lhs.groupId == rhs.groupId &&
            lhs.name == rhs.name)
    }

}

// MARK: - JSON Keys

extension Configuration {

    enum JSONKeys: JSONKey {
        case id
        case groupId = "group_id"
        case name
    }

}

extension Configuration: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        return [
            JSONKeys.name.rawValue
        ]
    }

}

// MARK: - Serialization

extension Configuration: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let id = json[JSONKeys.id.rawValue] as? Id,
            let groupId = json[JSONKeys.groupId.rawValue] as? ConfigurationGroup.Id,
            let name = json[JSONKeys.name.rawValue] as? String else {
                return nil
        }

        self.init(id: id, groupId: groupId, name: name)
    }

}

extension Configuration: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.id.rawValue: id,
                JSONKeys.groupId.rawValue: groupId,
                JSONKeys.name.rawValue: name]
    }

}

extension Configuration: UpdateRequestJSON { }
