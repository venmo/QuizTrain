import Foundation

public struct Result: CustomFields, Identifiable, Equatable {
    public typealias Id = Int
    public let assignedtoId: User.Id?
    public let comment: String?
    public let createdBy: User.Id
    public let createdOn: Date
    public let defects: String?
    public let elapsed: String?
    public let id: Id
    public let statusId: Status.Id?
    public let testId: Test.Id
    public let version: String?
    let customFieldsContainer: CustomFieldsContainer
    public var customFields: JSONDictionary {
        return self.customFieldsContainer.customFields
    }
}

// MARK: - Foward Relationships (ObjectAPI)

extension Result {

    public func assignedto(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<User?, ObjectAPI.GetError>) -> Void) {
        objectAPI.assignedto(self, completionHandler: completionHandler)
    }

    public func createdBy(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<User, ObjectAPI.GetError>) -> Void) {
        objectAPI.createdBy(self, completionHandler: completionHandler)
    }

    public func status(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Status?, ObjectAPI.MatchError<SingleMatchError<Result.Id>, ObjectAPI.GetError>>) -> Void) {
        objectAPI.status(self, completionHandler: completionHandler)
    }

    public func test(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Test, ObjectAPI.GetError>) -> Void) {
        objectAPI.test(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension Result {

    enum JSONKeys: JSONKey {
        case assignedtoId = "assignedto_id"
        case comment
        case createdBy = "created_by"
        case createdOn = "created_on"
        case defects
        case elapsed
        case id
        case statusId = "status_id"
        case testId = "test_id"
        case version
    }

}

// MARK: - Serialization

extension Result: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let createdBy = json[JSONKeys.createdBy.rawValue] as? User.Id,
            let createdOnSeconds = json[JSONKeys.createdOn.rawValue] as? Int,
            let id = json[JSONKeys.id.rawValue] as? Id,
            let testId = json[JSONKeys.testId.rawValue] as? Test.Id else {
                return nil
        }
        let createdOn = Date(secondsSince1970: createdOnSeconds)

        let assignedtoId = json[JSONKeys.assignedtoId.rawValue] as? User.Id ?? nil
        let comment = json[JSONKeys.comment.rawValue] as? String ?? nil
        let defects = json[JSONKeys.defects.rawValue] as? String ?? nil
        let elapsed = json[JSONKeys.elapsed.rawValue] as? String ?? nil
        let statusId = json[JSONKeys.statusId.rawValue] as? Status.Id ?? nil
        let version = json[JSONKeys.version.rawValue] as? String ?? nil

        let customFieldsContainer = CustomFieldsContainer(json: json)

        self.init(assignedtoId: assignedtoId, comment: comment, createdBy: createdBy, createdOn: createdOn, defects: defects, elapsed: elapsed, id: id, statusId: statusId, testId: testId, version: version, customFieldsContainer: customFieldsContainer)
    }

}

extension Result: JSONSerializable {

    private var serializedProperties: JSONDictionary {
        return [JSONKeys.assignedtoId.rawValue: assignedtoId as Any,
                JSONKeys.comment.rawValue: comment as Any,
                JSONKeys.createdBy.rawValue: createdBy,
                JSONKeys.createdOn.rawValue: createdOn.secondsSince1970,
                JSONKeys.defects.rawValue: defects as Any,
                JSONKeys.elapsed.rawValue: elapsed as Any,
                JSONKeys.id.rawValue: id,
                JSONKeys.statusId.rawValue: statusId as Any,
                JSONKeys.testId.rawValue: testId,
                JSONKeys.version.rawValue: version as Any]
    }

    func serialized() -> JSONDictionary {
        var json = serializedProperties
        customFields.forEach { item in json[item.key] = item.value }
        return json
    }

}
