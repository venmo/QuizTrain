public struct NewPlan: Equatable {

    public var description: String?
    public var entries: [NewPlan.Entry]?
    public var milestoneId: Milestone.Id?
    public var name: String

    public init(description: String? = nil, entries: [NewPlan.Entry]? = nil, milestoneId: Milestone.Id? = nil, name: String) {
        self.description = description
        self.entries = entries
        self.milestoneId = milestoneId
        self.name = name
    }

}

// MARK: - JSON Keys

extension NewPlan {

    enum JSONKeys: JSONKey {
        case description
        case entries
        case milestoneId = "milestone_id"
        case name
    }

}

extension NewPlan: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.description.rawValue,
                JSONKeys.entries.rawValue,
                JSONKeys.milestoneId.rawValue,
                JSONKeys.name.rawValue]
    }

}

// MARK: - Serialization

extension NewPlan: JSONSerializable {

    func serialized() -> JSONDictionary {

        let entriesSerialized: [JSONDictionary]?
        if let entries = entries {
            entriesSerialized = NewPlan.Entry.serialized(entries)
        } else {
            entriesSerialized = nil
        }

        return [JSONKeys.description.rawValue: description as Any,
                JSONKeys.entries.rawValue: entriesSerialized as Any,
                JSONKeys.milestoneId.rawValue: milestoneId as Any,
                JSONKeys.name.rawValue: name]
    }

}

extension NewPlan: AddRequestJSON { }
