import Foundation

public struct Project: Identifiable, Equatable {
    public typealias Id = Int
    public var announcement: String?
    public let completedOn: Date?
    public let id: Id
    public var isCompleted: Bool
    public var name: String
    public var showAnnouncement: Bool
    public var suiteMode: Project.SuiteMode
    public let url: URL
}

// MARK: - JSON Keys

extension Project {

    enum JSONKeys: JSONKey {
        case announcement
        case completedOn = "completed_on"
        case id
        case isCompleted = "is_completed"
        case name
        case showAnnouncement = "show_announcement"
        case suiteMode = "suite_mode"
        case url
    }

}

extension Project: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        return [
            JSONKeys.announcement.rawValue,
            JSONKeys.isCompleted.rawValue,
            JSONKeys.name.rawValue,
            JSONKeys.showAnnouncement.rawValue,
            JSONKeys.suiteMode.rawValue
        ]
    }

}

// MARK: - Serialization

extension Project: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let id = json[JSONKeys.id.rawValue] as? Id,
            let isCompleted = json[JSONKeys.isCompleted.rawValue] as? Bool,
            let name = json[JSONKeys.name.rawValue] as? String,
            let showAnnouncement = json[JSONKeys.showAnnouncement.rawValue] as? Bool,
            let suiteModeInt = json[JSONKeys.suiteMode.rawValue] as? Int,
            let suiteMode = Project.SuiteMode(rawValue: suiteModeInt),
            let urlString = json[JSONKeys.url.rawValue] as? String,
            let url = URL(string: urlString) else {
                return nil
        }

        let announcement = json[JSONKeys.announcement.rawValue] as? String ?? nil

        let completedOn: Date?
        if let seconds = json[JSONKeys.completedOn.rawValue] as? Int {
            completedOn = Date(secondsSince1970: seconds)
        } else {
            completedOn = nil
        }

        self.init(announcement: announcement, completedOn: completedOn, id: id, isCompleted: isCompleted, name: name, showAnnouncement: showAnnouncement, suiteMode: suiteMode, url: url)
    }

}

extension Project: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.announcement.rawValue: announcement as Any,
                JSONKeys.completedOn.rawValue: completedOn?.secondsSince1970 as Any,
                JSONKeys.id.rawValue: id,
                JSONKeys.isCompleted.rawValue: isCompleted,
                JSONKeys.name.rawValue: name,
                JSONKeys.showAnnouncement.rawValue: showAnnouncement,
                JSONKeys.suiteMode.rawValue: suiteMode.rawValue,
                JSONKeys.url.rawValue: url.absoluteString]
    }

}

extension Project: UpdateRequestJSON { }
