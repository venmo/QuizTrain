import Foundation

public struct Suite: Identifiable, Equatable {
    public typealias Id = Int
    public let completedOn: Date?
    public var description: String?
    public let id: Id
    public let isBaseline: Bool
    public let isCompleted: Bool
    public let isMaster: Bool
    public var name: String
    public let projectId: Project.Id
    public let url: URL
}

// MARK: - Foward Relationships (ObjectAPI)

extension Suite {

    public func project(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Project, ObjectAPI.GetError>) -> Void) {
        objectAPI.project(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension Suite {

    enum JSONKeys: JSONKey {
        case completedOn = "completed_on"
        case description = "description"
        case id
        case isBaseline = "is_baseline"
        case isCompleted = "is_completed"
        case isMaster = "is_master"
        case name
        case projectId = "project_id"
        case url
    }

}

extension Suite: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        return [
            JSONKeys.description.rawValue,
            JSONKeys.name.rawValue
        ]
    }

}

// MARK: - Serialization

extension Suite: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let id = json[JSONKeys.id.rawValue] as? Id,
            let isBaseline = json[JSONKeys.isBaseline.rawValue] as? Bool,
            let isCompleted = json[JSONKeys.isCompleted.rawValue] as? Bool,
            let isMaster = json[JSONKeys.isMaster.rawValue] as? Bool,
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

        let description = json[JSONKeys.description.rawValue] as? String ?? nil

        self.init(completedOn: completedOn, description: description, id: id, isBaseline: isBaseline, isCompleted: isCompleted, isMaster: isMaster, name: name, projectId: projectId, url: url)
    }

}

extension Suite: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.completedOn.rawValue: completedOn?.secondsSince1970 as Any,
                JSONKeys.description.rawValue: description as Any,
                JSONKeys.id.rawValue: id,
                JSONKeys.isBaseline.rawValue: isBaseline,
                JSONKeys.isCompleted.rawValue: isCompleted,
                JSONKeys.isMaster.rawValue: isMaster,
                JSONKeys.name.rawValue: name,
                JSONKeys.projectId.rawValue: projectId,
                JSONKeys.url.rawValue: url.absoluteString]
    }

}

extension Suite: UpdateRequestJSON { }
