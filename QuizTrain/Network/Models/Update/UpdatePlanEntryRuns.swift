/*
 Applies to all Run's within Plan.Entry.runs.
 */
public struct UpdatePlanEntryRuns: Equatable {

    public var assignedtoId: User.Id?
    public var caseIds: [Case.Id]?
    public var description: String?
    public var includeAll: Bool?

    public init(assignedtoId: User.Id? = nil, caseIds: [Case.Id]? = nil, description: String? = nil, includeAll: Bool? = nil) {
        self.assignedtoId = assignedtoId
        self.caseIds = caseIds
        self.description = description
        self.includeAll = includeAll
    }

}

// MARK: - JSON Keys

extension UpdatePlanEntryRuns {

    enum JSONKeys: JSONKey {
        case assignedtoId = "assignedto_id"
        case caseIds = "case_ids"
        case description
        case includeAll = "include_all"
    }

}

extension UpdatePlanEntryRuns: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        return [JSONKeys.assignedtoId.rawValue,
                JSONKeys.caseIds.rawValue,
                JSONKeys.description.rawValue,
                JSONKeys.includeAll.rawValue]
    }

}

// MARK: - Serialization

extension UpdatePlanEntryRuns: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.assignedtoId.rawValue: assignedtoId as Any,
                JSONKeys.caseIds.rawValue: caseIds as Any,
                JSONKeys.description.rawValue: description as Any,
                JSONKeys.includeAll.rawValue: includeAll as Any]
    }

}

extension UpdatePlanEntryRuns: UpdateRequestJSON { }
