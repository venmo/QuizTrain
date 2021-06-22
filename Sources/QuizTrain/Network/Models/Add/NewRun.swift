public struct NewRun: Equatable {

    public var assignedtoId: User.Id?
    public var caseIds: [Case.Id]?
    public var description: String?
    public var includeAll: Bool?
    public var milestoneId: Milestone.Id?
    public var name: String
    public var suiteId: Suite.Id? // Optional if project is running in single suite mode, otherwise required.

    public init(assignedtoId: User.Id? = nil, caseIds: [Case.Id]? = nil, description: String? = nil, includeAll: Bool? = nil, milestoneId: Milestone.Id? = nil, name: String, suiteId: Suite.Id? = nil) {
        self.assignedtoId = assignedtoId
        self.caseIds = caseIds
        self.description = description
        self.includeAll = includeAll
        self.milestoneId = milestoneId
        self.name = name
        self.suiteId = suiteId
    }

}

// MARK: - JSON Keys

extension NewRun {

    enum JSONKeys: JSONKey {
        case assignedtoId = "assignedto_id"
        case caseIds = "case_ids"
        case description
        case includeAll = "include_all"
        case milestoneId = "milestone_id"
        case name
        case suiteId = "suite_id"
    }

}

extension NewRun: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.assignedtoId.rawValue,
                JSONKeys.caseIds.rawValue,
                JSONKeys.description.rawValue,
                JSONKeys.includeAll.rawValue,
                JSONKeys.milestoneId.rawValue,
                JSONKeys.name.rawValue,
                JSONKeys.suiteId.rawValue]
    }

}

// MARK: - Serialization

extension NewRun: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.assignedtoId.rawValue: assignedtoId as Any,
                JSONKeys.caseIds.rawValue: caseIds as Any,
                JSONKeys.description.rawValue: description as Any,
                JSONKeys.includeAll.rawValue: includeAll as Any,
                JSONKeys.milestoneId.rawValue: milestoneId as Any,
                JSONKeys.name.rawValue: name,
                JSONKeys.suiteId.rawValue: suiteId as Any]
    }

}

extension NewRun: AddRequestJSON { }
