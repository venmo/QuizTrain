public struct Config: Identifiable, Equatable {
    public typealias Id = String
    typealias OptionsContainer = JSONDictionaryContainer
    public let context: Config.Context
    public let id: Id
    public var options: [String: Any] { return optionsContainer.json }
    let optionsContainer: OptionsContainer
}

// MARK: - Foward Relationships (ObjectAPI)

extension Config {

    public func accessibleProjects(_ objectAPI: ObjectAPI, completionHandler: @escaping(Outcome<[Project]?, ErrorContainer<ObjectAPI.GetError>>) -> Void) {
        objectAPI.accessibleProjects(self, completionHandler: completionHandler)
    }

    public func projects(_ objectAPI: ObjectAPI, completionHandler: @escaping(Outcome<[Project]?, ObjectAPI.MatchError<MultipleMatchError<Project, Project.Id>, ErrorContainer<ObjectAPI.GetError>>>) -> Void) {
        objectAPI.projects(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension Config {

    enum JSONKeys: JSONKey {
        case context
        case id
        case options
    }

}

// MARK: - Serialization

extension Config: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let contextJson = json[JSONKeys.context.rawValue] as? JSONDictionary,
            let context: Config.Context = Config.Context.deserialized(contextJson),
            let id = json[JSONKeys.id.rawValue] as? Id,
            let options = json[JSONKeys.options.rawValue] as? [String: Any] else {
                return nil
        }

        let optionsContainer = OptionsContainer(json: options)

        self.init(context: context, id: id, optionsContainer: optionsContainer)
    }

}

extension Config: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.context.rawValue: context.serialized(),
                JSONKeys.id.rawValue: id,
                JSONKeys.options.rawValue: options]
    }

}

// MARK: - ProjectSelection

extension Config {

    var projects: UniqueSelection<Project.Id> {
        if context.isGlobal == true {
            return .all
        } else if let projectIds = context.projectIds {
            return .some(Set(projectIds))
        }
        return .none
    }

}
