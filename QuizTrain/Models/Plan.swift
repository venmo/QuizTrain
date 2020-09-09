import Foundation

public struct Plan: Identifiable, Equatable {
    public typealias Id = Int
    public let assignedtoId: User.Id?
    public let blockedCount: Int
    public let completedOn: Date?
    public let createdBy: User.Id
    public let createdOn: Date
    public let customStatus1Count: Int
    public let customStatus2Count: Int
    public let customStatus3Count: Int
    public let customStatus4Count: Int
    public let customStatus5Count: Int
    public let customStatus6Count: Int
    public let customStatus7Count: Int
    public var description: String?
    public let entries: [Plan.Entry]?                                           // Certain API calls will always return nil for this value. Others will only return a single entry. See TestRail API documentation for details.
    public let failedCount: Int
    public let id: Id
    public let isCompleted: Bool
    public var milestoneId: Milestone.Id?
    public var name: String
    public let passedCount: Int
    public let projectId: Project.Id
    public let retestCount: Int
    public let untestedCount: Int
    public let url: URL
}

// MARK: - Foward Relationships (ObjectAPI)

extension Plan {

    public func assignedto(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<User?, ObjectAPI.GetError>) -> Void) {
        objectAPI.assignedto(self, completionHandler: completionHandler)
    }

    public func createdBy(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<User, ObjectAPI.GetError>) -> Void) {
        objectAPI.createdBy(self, completionHandler: completionHandler)
    }

    public func milestone(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Milestone?, ObjectAPI.GetError>) -> Void) {
        objectAPI.milestone(self, completionHandler: completionHandler)
    }

    public func project(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Project, ObjectAPI.GetError>) -> Void) {
        objectAPI.project(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension Plan {

    enum JSONKeys: JSONKey {
        case assignedtoId = "assignedto_id"
        case blockedCount = "blocked_count"
        case completedOn = "completed_on"
        case createdBy = "created_by"
        case createdOn = "created_on"
        case customStatus1Count = "custom_status1_count"
        case customStatus2Count = "custom_status2_count"
        case customStatus3Count = "custom_status3_count"
        case customStatus4Count = "custom_status4_count"
        case customStatus5Count = "custom_status5_count"
        case customStatus6Count = "custom_status6_count"
        case customStatus7Count = "custom_status7_count"
        case description
        case entries
        case failedCount = "failed_count"
        case id
        case isCompleted = "is_completed"
        case milestoneId = "milestone_id"
        case name
        case passedCount = "passed_count"
        case projectId = "project_id"
        case retestCount = "retest_count"
        case untestedCount = "untested_count"
        case url
    }

}

extension Plan: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        return [
            JSONKeys.description.rawValue,
            JSONKeys.milestoneId.rawValue,
            JSONKeys.name.rawValue
        ]
    }

}

// MARK: - Serialization

extension Plan: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let blockedCount = json[JSONKeys.blockedCount.rawValue] as? Int,
            let createdBy = json[JSONKeys.createdBy.rawValue] as? User.Id,
            let createdOnSeconds = json[JSONKeys.createdOn.rawValue] as? Int,
            let customStatus1Count = json[JSONKeys.customStatus1Count.rawValue] as? Int,
            let customStatus2Count = json[JSONKeys.customStatus2Count.rawValue] as? Int,
            let customStatus3Count = json[JSONKeys.customStatus3Count.rawValue] as? Int,
            let customStatus4Count = json[JSONKeys.customStatus4Count.rawValue] as? Int,
            let customStatus5Count = json[JSONKeys.customStatus5Count.rawValue] as? Int,
            let customStatus6Count = json[JSONKeys.customStatus6Count.rawValue] as? Int,
            let customStatus7Count = json[JSONKeys.customStatus7Count.rawValue] as? Int,
            let failedCount = json[JSONKeys.failedCount.rawValue] as? Int,
            let id = json[JSONKeys.id.rawValue] as? Id,
            let isCompleted = json[JSONKeys.isCompleted.rawValue] as? Bool,
            let name = json[JSONKeys.name.rawValue] as? String,
            let passedCount = json[JSONKeys.passedCount.rawValue] as? Int,
            let projectId = json[JSONKeys.projectId.rawValue] as? Project.Id,
            let retestCount = json[JSONKeys.retestCount.rawValue] as? Int,
            let untestedCount = json[JSONKeys.untestedCount.rawValue] as? Int,
            let urlString = json[JSONKeys.url.rawValue] as? String,
            let url = URL(string: urlString) else {
                return nil
        }
        let createdOn = Date(secondsSince1970: createdOnSeconds)

        let completedOn: Date?
        if let seconds = json[JSONKeys.completedOn.rawValue] as? Int {
            completedOn = Date(secondsSince1970: seconds)
        } else {
            completedOn = nil
        }

        let assignedtoId = json[JSONKeys.assignedtoId.rawValue] as? User.Id ?? nil
        let description = json[JSONKeys.description.rawValue] as? String ?? nil
        let milestoneId = json[JSONKeys.milestoneId.rawValue] as? Milestone.Id ?? nil
        let entriesJson = json[JSONKeys.entries.rawValue] as? [JSONDictionary] ?? nil
        let entries: [Plan.Entry]? = entriesJson != nil ? Plan.Entry.deserialized(entriesJson!) : nil

        self.init(assignedtoId: assignedtoId, blockedCount: blockedCount, completedOn: completedOn, createdBy: createdBy, createdOn: createdOn, customStatus1Count: customStatus1Count, customStatus2Count: customStatus2Count, customStatus3Count: customStatus3Count, customStatus4Count: customStatus4Count, customStatus5Count: customStatus5Count, customStatus6Count: customStatus6Count, customStatus7Count: customStatus7Count, description: description, entries: entries, failedCount: failedCount, id: id, isCompleted: isCompleted, milestoneId: milestoneId, name: name, passedCount: passedCount, projectId: projectId, retestCount: retestCount, untestedCount: untestedCount, url: url)
    }

}

extension Plan: JSONSerializable {

    func serialized() -> JSONDictionary {

        let entriesSerialized: [JSONDictionary]?
        if let entries = self.entries {
            entriesSerialized = Plan.Entry.serialized(entries)
        } else {
            entriesSerialized = nil
        }

        return [JSONKeys.assignedtoId.rawValue: assignedtoId as Any,
                JSONKeys.blockedCount.rawValue: blockedCount,
                JSONKeys.completedOn.rawValue: completedOn?.secondsSince1970 as Any,
                JSONKeys.createdBy.rawValue: createdBy,
                JSONKeys.createdOn.rawValue: createdOn.secondsSince1970,
                JSONKeys.customStatus1Count.rawValue: customStatus1Count,
                JSONKeys.customStatus2Count.rawValue: customStatus2Count,
                JSONKeys.customStatus3Count.rawValue: customStatus3Count,
                JSONKeys.customStatus4Count.rawValue: customStatus4Count,
                JSONKeys.customStatus5Count.rawValue: customStatus5Count,
                JSONKeys.customStatus6Count.rawValue: customStatus6Count,
                JSONKeys.customStatus7Count.rawValue: customStatus7Count,
                JSONKeys.description.rawValue: description as Any,
                JSONKeys.entries.rawValue: entriesSerialized as Any,
                JSONKeys.failedCount.rawValue: failedCount,
                JSONKeys.id.rawValue: id,
                JSONKeys.isCompleted.rawValue: isCompleted,
                JSONKeys.milestoneId.rawValue: milestoneId as Any,
                JSONKeys.name.rawValue: name,
                JSONKeys.passedCount.rawValue: passedCount,
                JSONKeys.projectId.rawValue: projectId,
                JSONKeys.retestCount.rawValue: retestCount,
                JSONKeys.untestedCount.rawValue: untestedCount,
                JSONKeys.url.rawValue: url.absoluteString]
    }

}

extension Plan: UpdateRequestJSON { }
