extension Config {

    public struct Context: Equatable {
        public let isGlobal: Bool                                               // True indicates all projects.
        public let projectIds: [Project.Id]?                                    // Applies only if isGlobal is false. Can include projectIds for projects you do not have at least Read-only access to.
    }

}

// MARK: - JSON Keys

extension Config.Context {

    enum JSONKeys: JSONKey {
        case isGlobal = "is_global"
        case projectIds = "project_ids"
    }

}

// MARK: - Serialization

extension Config.Context: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let isGlobal = json[JSONKeys.isGlobal.rawValue] as? Bool else {
            return nil
        }

        let projectIds = json[JSONKeys.projectIds.rawValue] as? [Project.Id] ?? nil

        self.init(isGlobal: isGlobal, projectIds: projectIds)
    }

}

extension Config.Context: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.isGlobal.rawValue: isGlobal,
                JSONKeys.projectIds.rawValue: projectIds as Any]
    }

}
