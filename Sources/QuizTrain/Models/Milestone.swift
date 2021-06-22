import Foundation

public struct Milestone: Identifiable, Equatable {
    public typealias Id = Int
    public let completedOn: Date?
    public var description: String?
    public var dueOn: Date?
    public let id: Id
    public var isCompleted: Bool
    public var isStarted: Bool
    public let milestones: [Milestone]?                                         // Certain API calls will always return nil for this value. See TestRail API documentation for details.
    public var name: String
    public var parentId: Id?
    public let projectId: Project.Id
    public var startOn: Date?
    public let startedOn: Date?
    public let url: URL
}

// MARK: - Foward Relationships (ObjectAPI)

extension Milestone {

    public func parent(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Milestone?, ObjectAPI.GetError>) -> Void) {
        objectAPI.parent(self, completionHandler: completionHandler)
    }

    public func project(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Project, ObjectAPI.GetError>) -> Void) {
        objectAPI.project(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension Milestone {

    enum JSONKeys: JSONKey {
        case completedOn = "completed_on"
        case description
        case dueOn = "due_on"
        case id
        case isCompleted = "is_completed"
        case isStarted = "is_started"
        case milestones
        case name
        case parentId = "parent_id"
        case projectId = "project_id"
        case startOn = "start_on"
        case startedOn = "started_on"
        case url
    }

}

extension Milestone: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        return [
            JSONKeys.description.rawValue,
            JSONKeys.dueOn.rawValue,
            JSONKeys.isCompleted.rawValue,
            JSONKeys.isStarted.rawValue,
            JSONKeys.name.rawValue,
            JSONKeys.parentId.rawValue,
            JSONKeys.startOn.rawValue
        ]
    }

}

// MARK: - Serialization

extension Milestone: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let id = json[JSONKeys.id.rawValue] as? Id,
            let isCompleted = json[JSONKeys.isCompleted.rawValue] as? Bool,
            let isStarted = json[JSONKeys.isStarted.rawValue] as? Bool,
            let name = json[JSONKeys.name.rawValue] as? String,
            let projectId = json[JSONKeys.projectId.rawValue] as? Project.Id,
            let urlString = json[JSONKeys.url.rawValue] as? String,
            let url = URL(string: urlString) else {
                return nil
        }

        let completedOn: Date?
        if let seconds = json[JSONKeys.completedOn.rawValue] as? Int {
            completedOn = Date(secondsSince1970: seconds)
        } else {
            completedOn = nil
        }

        let dueOn: Date?
        if let seconds = json[JSONKeys.dueOn.rawValue] as? Int {
            dueOn = Date(secondsSince1970: seconds)
        } else {
            dueOn = nil
        }

        let startOn: Date?
        if let seconds = json[JSONKeys.startOn.rawValue] as? Int {
            startOn = Date(secondsSince1970: seconds)
        } else {
            startOn = nil
        }

        let startedOn: Date?
        if let seconds = json[JSONKeys.startedOn.rawValue] as? Int {
            startedOn = Date(secondsSince1970: seconds)
        } else {
            startedOn = nil
        }

        let description = json[JSONKeys.description.rawValue] as? String ?? nil
        let milestones: [Milestone]?
        if let milestonesJson = json[JSONKeys.milestones.rawValue] as? [JSONDictionary] {
            milestones = Milestone.deserialized(milestonesJson)
        } else {
            milestones = nil
        }
        let parentId = json[JSONKeys.parentId.rawValue] as? Id ?? nil

        self.init(completedOn: completedOn, description: description, dueOn: dueOn, id: id, isCompleted: isCompleted, isStarted: isStarted, milestones: milestones, name: name, parentId: parentId, projectId: projectId, startOn: startOn, startedOn: startedOn, url: url)
    }

}

extension Milestone: JSONSerializable {

    func serialized() -> JSONDictionary {

        let milestonesSerialized: [JSONDictionary]?
        if let milestones = self.milestones {
            milestonesSerialized = Milestone.serialized(milestones)
        } else {
            milestonesSerialized = nil
        }

        return [JSONKeys.completedOn.rawValue: completedOn?.secondsSince1970 as Any,
                JSONKeys.description.rawValue: description as Any,
                JSONKeys.dueOn.rawValue: dueOn?.secondsSince1970 as Any,
                JSONKeys.id.rawValue: id,
                JSONKeys.isCompleted.rawValue: isCompleted,
                JSONKeys.isStarted.rawValue: isStarted,
                JSONKeys.milestones.rawValue: milestonesSerialized as Any,
                JSONKeys.name.rawValue: name,
                JSONKeys.parentId.rawValue: parentId as Any,
                JSONKeys.projectId.rawValue: projectId,
                JSONKeys.startOn.rawValue: startOn?.secondsSince1970 as Any,
                JSONKeys.startedOn.rawValue: startedOn?.secondsSince1970 as Any,
                JSONKeys.url.rawValue: url.absoluteString]
    }

}

extension Milestone: UpdateRequestJSON { }
