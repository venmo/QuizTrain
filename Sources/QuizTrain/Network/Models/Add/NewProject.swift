public struct NewProject: Equatable {

    public var announcement: String?
    public var name: String
    public var showAnnouncement: Bool
    public var suiteMode: Project.SuiteMode

    public init(announcement: String? = nil, name: String, showAnnouncement: Bool, suiteMode: Project.SuiteMode) {
        self.announcement = announcement
        self.name = name
        self.showAnnouncement = showAnnouncement
        self.suiteMode = suiteMode
    }

}

// MARK: - JSON Keys

extension NewProject {

    enum JSONKeys: JSONKey {
        case announcement
        case name
        case showAnnouncement = "show_announcement"
        case suiteMode = "suite_mode"
    }

}

extension NewProject: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        return [JSONKeys.announcement.rawValue,
                JSONKeys.name.rawValue,
                JSONKeys.showAnnouncement.rawValue,
                JSONKeys.suiteMode.rawValue]
    }

}

// MARK: - Serialization

extension NewProject: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.announcement.rawValue: announcement as Any,
                JSONKeys.name.rawValue: name,
                JSONKeys.showAnnouncement.rawValue: showAnnouncement,
                JSONKeys.suiteMode.rawValue: suiteMode.rawValue]
    }

}

extension NewProject: AddRequestJSON { }
