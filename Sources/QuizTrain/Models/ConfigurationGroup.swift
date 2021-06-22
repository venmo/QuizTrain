public struct ConfigurationGroup: Identifiable, Equatable {
    public typealias Id = Int
    public let configs: [Configuration]
    public let id: Id
    public var name: String
    public let projectId: Project.Id
}

// MARK: - Foward Relationships (ObjectAPI)

extension ConfigurationGroup {

    public func project(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Project, ObjectAPI.GetError>) -> Void) {
        objectAPI.project(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension ConfigurationGroup {

    enum JSONKeys: JSONKey {
        case configs
        case id
        case name
        case projectId = "project_id"
    }

}

extension ConfigurationGroup: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        return [
            JSONKeys.name.rawValue
        ]
    }

}

// MARK: - Serialization

extension ConfigurationGroup: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let configsJson = json[JSONKeys.configs.rawValue] as? [JSONDictionary],
            let configs: [Configuration] = ConfigurationGroup.deserialized(configsJson),
            let id = json[JSONKeys.id.rawValue] as? Id,
            let name = json[JSONKeys.name.rawValue] as? String,
            let projectId = json[JSONKeys.projectId.rawValue] as? Project.Id else {
                return nil
        }

        self.init(configs: configs, id: id, name: name, projectId: projectId)
    }

}

extension ConfigurationGroup: JSONSerializable {

    func serialized() -> JSONDictionary {

        let configsSerialized: [JSONDictionary] = Configuration.serialized(configs)

        return [JSONKeys.configs.rawValue: configsSerialized,
                JSONKeys.id.rawValue: id,
                JSONKeys.name.rawValue: name,
                JSONKeys.projectId.rawValue: projectId]
    }

}

extension ConfigurationGroup: UpdateRequestJSON { }
