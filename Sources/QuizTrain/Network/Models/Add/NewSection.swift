public struct NewSection: Equatable {

    public var description: String?
    public var name: String
    public var parentId: Section.Id?
    public var suiteId: Suite.Id? // Optional/ignored if project is running in single suite mode, otherwise required.

    public init(description: String? = nil, name: String, parentId: Section.Id? = nil, suiteId: Suite.Id? = nil) {
        self.description = description
        self.name = name
        self.parentId = parentId
        self.suiteId = suiteId
    }

}

// MARK: - JSON Keys

extension NewSection {

    enum JSONKeys: JSONKey {
        case description
        case name
        case parentId = "parent_id"
        case suiteId = "suite_id"
    }

}

extension NewSection: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.description.rawValue,
                JSONKeys.name.rawValue,
                JSONKeys.parentId.rawValue,
                JSONKeys.suiteId.rawValue]
    }

}

// MARK: - Serialization

extension NewSection: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.description.rawValue: description as Any,
                JSONKeys.name.rawValue: name,
                JSONKeys.parentId.rawValue: parentId as Any,
                JSONKeys.suiteId.rawValue: suiteId as Any]
    }

}

extension NewSection: AddRequestJSON { }
