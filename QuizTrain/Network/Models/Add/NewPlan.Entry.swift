extension NewPlan {

    public struct Entry: Equatable {

        public var assignedtoId: User.Id?                                       // Default for all runs with a nil assignedtoId.
        public var caseIds: [Case.Id]?                                          // Default for all runs with a nil or empty caseIds.
        public var description: String?                                         // Default for all runs with a nil description.
        public var includeAll: Bool?                                            // Default for all runs with a nil includeAll.
        public var name: String?                                                // Default for all runs with a nil name.
        public var runs: [NewPlan.Entry.Run]?                                   // If nil TestRail will return a single run including either all tests (includeAll), or specific tests (caseIds), from the suiteId without using configurations.
        public var suiteId: Suite.Id                                            // Default for all runs with a nil suiteId.

        public init(assignedtoId: User.Id? = nil, caseIds: [Case.Id]? = nil, description: String? = nil, includeAll: Bool? = nil, name: String? = nil, runs: [NewPlan.Entry.Run]? = nil, suiteId: Suite.Id) {
            self.assignedtoId = assignedtoId
            self.caseIds = caseIds
            self.description = description
            self.includeAll = includeAll
            self.name = name
            self.runs = runs
            self.suiteId = suiteId
        }

        /*
         Contains every Configuration.id from all runs.
         http://docs.gurock.com/testrail-api2/reference-plans#add_plan_entry
         */
        public var configIds: [Int]? {

            guard let runs = self.runs else {
                return nil
            }

            var ids = [Int]()
            var allRunConfigIdsAreNil = true

            for run in runs {
                guard let runConfigIds = run.configIds else {
                    continue
                }
                allRunConfigIdsAreNil = false
                ids.append(contentsOf: runConfigIds)
            }

            guard allRunConfigIdsAreNil == false else {
                return nil // If every run has a nil value for configIds nil is returned match the runs.
            }

            ids = Array(Set(ids)) // Remove duplicates.
            ids.sort() // Maintain a consistent order for Equatable.

            return ids
        }
    }

}

// MARK: - JSON Keys

extension NewPlan.Entry {

    enum JSONKeys: JSONKey {
        case assignedtoId = "assignedto_id"
        case caseIds = "case_ids"
        case configIds = "config_ids"
        case description
        case includeAll = "include_all"
        case name
        case runs
        case suiteId = "suite_id"
    }

}

extension NewPlan.Entry: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.assignedtoId.rawValue,
                JSONKeys.caseIds.rawValue,
                JSONKeys.configIds.rawValue,
                JSONKeys.description.rawValue,
                JSONKeys.includeAll.rawValue,
                JSONKeys.name.rawValue,
                JSONKeys.runs.rawValue,
                JSONKeys.suiteId.rawValue]
    }

}

// MARK: - Serialization

extension NewPlan.Entry: JSONSerializable {

    func serialized() -> JSONDictionary {

        let runsSerialized: [JSONDictionary]?
        if let runs = self.runs {
            runsSerialized = NewRun.serialized(runs)
        } else {
            runsSerialized = nil
        }

        return [JSONKeys.assignedtoId.rawValue: assignedtoId as Any,
                JSONKeys.caseIds.rawValue: caseIds as Any,
                JSONKeys.configIds.rawValue: configIds as Any,
                JSONKeys.description.rawValue: description as Any,
                JSONKeys.includeAll.rawValue: includeAll as Any,
                JSONKeys.name.rawValue: name as Any,
                JSONKeys.runs.rawValue: runsSerialized as Any,
                JSONKeys.suiteId.rawValue: suiteId]
    }

}

extension NewPlan.Entry: AddRequestJSON { }
