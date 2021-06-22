import Foundation

public struct NewMilestone: Equatable {

    public var description: String?
    public var dueOn: Date?
    public var name: String
    public var parentId: Milestone.Id?
    public var startOn: Date?

    public init(description: String? = nil, dueOn: Date? = nil, name: String, parentId: Milestone.Id? = nil, startOn: Date? = nil) {
        self.description = description
        self.dueOn = dueOn
        self.name = name
        self.parentId = parentId
        self.startOn = startOn
    }

}

// MARK: - JSON Keys

extension NewMilestone {

    enum JSONKeys: JSONKey {
        case description
        case dueOn = "due_on"
        case name
        case parentId = "parent_id"
        case startOn = "start_on"
    }

}

extension NewMilestone: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.description.rawValue,
                JSONKeys.dueOn.rawValue,
                JSONKeys.name.rawValue,
                JSONKeys.parentId.rawValue,
                JSONKeys.startOn.rawValue]
    }

}

// MARK: - Serialization

extension NewMilestone: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.description.rawValue: description as Any,
                JSONKeys.dueOn.rawValue: dueOn?.secondsSince1970 as Any,
                JSONKeys.name.rawValue: name,
                JSONKeys.parentId.rawValue: parentId as Any,
                JSONKeys.startOn.rawValue: startOn?.secondsSince1970 as Any]
    }

}

extension NewMilestone: AddRequestJSON { }
