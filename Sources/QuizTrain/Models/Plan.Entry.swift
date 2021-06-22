extension Plan {

    public struct Entry: Identifiable, Equatable {
        public typealias Id = String
        public let id: Id
        public var name: String
        public let runs: [Run]                                                  // NOTE: Runs can be updated using a PlanEntryRunsData. See ObjectAPI for details.
        public let suiteId: Suite.Id
    }

}

// MARK: - Foward Relationships (ObjectAPI)

extension Plan.Entry {

    public func suite(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Suite, ObjectAPI.GetError>) -> Void) {
        objectAPI.suite(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension Plan.Entry {

    enum JSONKeys: JSONKey {
        case id
        case name
        case runs
        case suiteId = "suite_id"
    }

}

extension Plan.Entry: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        return [JSONKeys.name.rawValue]
    }

}

// MARK: - Serialization

extension Plan.Entry: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let id = json[JSONKeys.id.rawValue] as? Id,
            let name = json[JSONKeys.name.rawValue] as? String,
            let runsJson = json[JSONKeys.runs.rawValue] as? [JSONDictionary],
            let runs: [Run] = Run.deserialized(runsJson),
            let suiteId = json[JSONKeys.suiteId.rawValue] as? Suite.Id else {
                return nil
        }

        self.init(id: id, name: name, runs: runs, suiteId: suiteId)
    }

}

extension Plan.Entry: JSONSerializable {

    func serialized() -> JSONDictionary {

        let runsSerialized: [JSONDictionary] = Run.serialized(runs)

        return [JSONKeys.id.rawValue: id,
                JSONKeys.name.rawValue: name,
                JSONKeys.runs.rawValue: runsSerialized,
                JSONKeys.suiteId.rawValue: suiteId]
    }

}

extension Plan.Entry: UpdateRequestJSON { }
