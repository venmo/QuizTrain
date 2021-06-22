/*
 Each NewPlan.Entry.Run can be assigned to zero or more Configuration's so long
 as there is no more than one Configuration per ConfigurationGroup. For example:

 - Group1
   - ConfigurationA.id = 100
   - ConfigurationB.id = 101
 - Group2
   - ConfigurationC.id = 200
   - ConfigurationD.id = 201

 Valid NewPlan.Entry.Run.configIds values include:

 nil                // No configurations will be used.
 []                 // No configurations will be used.
 [100]              // ConfigurationA will be used.
 [100, 200]         // ConfigurationA and ConfigurationC will be used.
 [100, 201]         // ConfigurationA and ConfigurationD will be used.

 Invalid values include:

 [100, 101]         // Both are from Group1.
 [200, 202]         // Both are from Group2.
 [100, 200, 201]    // 200 and 201 are from Group2.
 */
extension NewPlan.Entry {

    public struct Run: Equatable {

        public var assignedtoId: User.Id?                                       // Overrides NewPlan.Entry.assignedtoId.
        public var caseIds: [Case.Id]?                                          // Overrides NewPlan.Entry.caseIds.
        public var configIds: [Configuration.Id]?                               // Zero, one, or many Configuration.id's. Only one Configuration.id per ConfigurationGroup is allowed.
        public var description: String?                                         // Overrides NewPlan.Entry.caseIds.description.
        public var includeAll: Bool?                                            // Overrides NewPlan.Entry.includeAll.
        public var milestoneId: Milestone.Id?                                   // Milestone for the run.
        public var name: String?                                                // Overrides NewPlan.Entry.name
        public var suiteId: Suite.Id?                                           // Overrides NewPlan.Entry.suiteId

        public init(assignedtoId: User.Id? = nil, caseIds: [Case.Id]? = nil, configIds: [Configuration.Id]? = nil, description: String? = nil, includeAll: Bool? = nil, milestoneId: Milestone.Id? = nil, name: String? = nil, suiteId: Suite.Id? = nil) {
            self.assignedtoId = assignedtoId
            self.caseIds = caseIds
            self.configIds = configIds
            self.description = description
            self.includeAll = includeAll
            self.milestoneId = milestoneId
            self.name = name
            self.suiteId = suiteId
        }

    }

}

// MARK: - JSON Keys

extension NewPlan.Entry.Run {

    enum JSONKeys: JSONKey {
        case assignedtoId = "assignedto_id"
        case caseIds = "case_ids"
        case configIds = "config_ids"
        case description
        case includeAll = "include_all"
        case milestoneId = "milestone_id"
        case name
        case suiteId = "suite_id"
    }

}

extension NewPlan.Entry.Run: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.assignedtoId.rawValue,
                JSONKeys.caseIds.rawValue,
                JSONKeys.configIds.rawValue,
                JSONKeys.description.rawValue,
                JSONKeys.includeAll.rawValue,
                JSONKeys.milestoneId.rawValue,
                JSONKeys.name.rawValue,
                JSONKeys.suiteId.rawValue]
    }

}

// MARK: - Serialization

extension NewPlan.Entry.Run: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.assignedtoId.rawValue: assignedtoId as Any,
                JSONKeys.caseIds.rawValue: caseIds as Any,
                JSONKeys.configIds.rawValue: configIds as Any,
                JSONKeys.description.rawValue: description as Any,
                JSONKeys.includeAll.rawValue: includeAll as Any,
                JSONKeys.milestoneId.rawValue: milestoneId as Any,
                JSONKeys.name.rawValue: name as Any,
                JSONKeys.suiteId.rawValue: suiteId as Any]
    }

}

extension NewPlan.Entry.Run: AddRequestJSON { }
