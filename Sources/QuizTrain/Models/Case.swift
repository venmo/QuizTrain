import Foundation

public struct Case: Identifiable, MutableCustomFields, Equatable {
    public typealias Id = Int
    public let createdBy: User.Id
    public let createdOn: Date
    public var estimate: String?
    public let estimateForecast: String?
    public let id: Id
    public var milestoneId: Milestone.Id?
    public var priorityId: Priority.Id
    public var refs: String?
    public let sectionId: Section.Id?
    public let suiteId: Suite.Id?
    public var templateId: Template.Id
    public var title: String
    public var typeId: CaseType.Id
    public let updatedBy: User.Id
    public let updatedOn: Date
    var customFieldsContainer: CustomFieldsContainer
    public var customFields: JSONDictionary {
        get { return self.customFieldsContainer.customFields }
        set { customFieldsContainer.customFields = newValue }
    }
}

// MARK: - Foward Relationships (ObjectAPI)

extension Case {

    public func createdBy(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<User, ObjectAPI.GetError>) -> Void) {
        objectAPI.createdBy(self, completionHandler: completionHandler)
    }

    public func milestone(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Milestone?, ObjectAPI.GetError>) -> Void) {
        objectAPI.milestone(self, completionHandler: completionHandler)
    }

    public func priority(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Priority, ObjectAPI.MatchError<SingleMatchError<Case.Id>, ObjectAPI.GetError>>) -> Void) {
        objectAPI.priority(self, completionHandler: completionHandler)
    }

    public func section(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Section?, ObjectAPI.GetError>) -> Void) {
        objectAPI.section(self, completionHandler: completionHandler)
    }

    public func suite(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Suite?, ObjectAPI.GetError>) -> Void) {
        objectAPI.suite(self, completionHandler: completionHandler)
    }

    public func template(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Template, ObjectAPI.MatchError<SingleMatchError<Case.Id>, ErrorContainer<ObjectAPI.GetError>>>) -> Void) {
        objectAPI.template(self, completionHandler: completionHandler)
    }

    public func type(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<CaseType, ObjectAPI.MatchError<SingleMatchError<Case.Id>, ObjectAPI.GetError>>) -> Void) {
        objectAPI.type(self, completionHandler: completionHandler)
    }

    public func updatedBy(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<User, ObjectAPI.GetError>) -> Void) {
        objectAPI.updatedBy(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension Case {

    enum JSONKeys: JSONKey {
        case createdBy = "created_by"
        case createdOn = "created_on"
        case estimate
        case estimateForecast = "estimate_forecast"
        case id
        case milestoneId = "milestone_id"
        case priorityId = "priority_id"
        case refs
        case sectionId = "section_id"
        case suiteId = "suite_id"
        case templateId = "template_id"
        case title
        case typeId = "type_id"
        case updatedBy = "updated_by"
        case updatedOn = "updated_on"
    }

}

extension Case: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        var keys = [
            JSONKeys.estimate.rawValue,
            JSONKeys.milestoneId.rawValue,
            JSONKeys.priorityId.rawValue,
            JSONKeys.refs.rawValue,
            JSONKeys.templateId.rawValue,
            JSONKeys.title.rawValue,
            JSONKeys.typeId.rawValue
        ]
        keys += self.customFieldsContainer.customFields.keys
        return keys
    }

}

// MARK: - Serialization

extension Case: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let createdBy = json[JSONKeys.createdBy.rawValue] as? User.Id,
            let createdOnSeconds = json[JSONKeys.createdOn.rawValue] as? Int,
            let id = json[JSONKeys.id.rawValue] as? Id,
            let priorityId = json[JSONKeys.priorityId.rawValue] as? Priority.Id,
            let templateId = json[JSONKeys.templateId.rawValue] as? Template.Id,
            let title = json[JSONKeys.title.rawValue] as? String,
            let typeId = json[JSONKeys.typeId.rawValue] as? CaseType.Id,
            let updatedBy = json[JSONKeys.updatedBy.rawValue] as? User.Id,
            let updatedOnSeconds = json[JSONKeys.updatedOn.rawValue] as? Int else {
                return nil
        }
        let createdOn = Date(secondsSince1970: createdOnSeconds)
        let updatedOn = Date(secondsSince1970: updatedOnSeconds)

        let estimate = json[JSONKeys.estimate.rawValue] as? String ?? nil
        let estimateForecast = json[JSONKeys.estimateForecast.rawValue] as? String ?? nil
        let milestoneId = json[JSONKeys.milestoneId.rawValue] as? Milestone.Id ?? nil
        let refs = json[JSONKeys.refs.rawValue] as? String ?? nil
        let sectionId = json[JSONKeys.sectionId.rawValue] as? Section.Id ?? nil
        let suiteId = json[JSONKeys.suiteId.rawValue] as? Suite.Id ?? nil

        let customFieldsContainer = CustomFieldsContainer(json: json)

        self.init(createdBy: createdBy, createdOn: createdOn, estimate: estimate, estimateForecast: estimateForecast, id: id, milestoneId: milestoneId, priorityId: priorityId, refs: refs, sectionId: sectionId, suiteId: suiteId, templateId: templateId, title: title, typeId: typeId, updatedBy: updatedBy, updatedOn: updatedOn, customFieldsContainer: customFieldsContainer)
    }

}

extension Case: JSONSerializable {

    private var serializedProperties: JSONDictionary {
        return [JSONKeys.createdBy.rawValue: createdBy,
                JSONKeys.createdOn.rawValue: createdOn.secondsSince1970,
                JSONKeys.estimate.rawValue: estimate as Any,
                JSONKeys.estimateForecast.rawValue: estimateForecast as Any,
                JSONKeys.id.rawValue: id,
                JSONKeys.milestoneId.rawValue: milestoneId as Any,
                JSONKeys.priorityId.rawValue: priorityId,
                JSONKeys.refs.rawValue: refs as Any,
                JSONKeys.templateId.rawValue: templateId,
                JSONKeys.title.rawValue: title,
                JSONKeys.typeId.rawValue: typeId,
                JSONKeys.sectionId.rawValue: sectionId as Any,
                JSONKeys.suiteId.rawValue: suiteId as Any,
                JSONKeys.updatedBy.rawValue: updatedBy,
                JSONKeys.updatedOn.rawValue: updatedOn.secondsSince1970]
    }

    func serialized() -> JSONDictionary {
        var json = serializedProperties
        customFields.forEach { item in json[item.key] = item.value }
        return json
    }

}

extension Case: UpdateRequestJSON { }
