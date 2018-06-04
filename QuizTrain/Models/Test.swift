public struct Test: CustomFields, Identifiable, Equatable {
    public typealias Id = Int
    public let assignedtoId: User.Id?
    public let caseId: Case.Id
    public let estimate: String?
    public let estimateForecast: String?
    public let id: Id
    public let milestoneId: Milestone.Id?
    public let priorityId: Priority.Id
    public let refs: String?
    public let runId: Run.Id
    public let statusId: Status.Id
    public let templateId: Template.Id
    public let title: String
    public let typeId: CaseType.Id
    let customFieldsContainer: CustomFieldsContainer
    public var customFields: JSONDictionary {
        return self.customFieldsContainer.customFields
    }
}

// MARK: - Foward Relationships (ObjectAPI)

extension Test {

    public func assignedto(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<User?, ObjectAPI.GetError>) -> Void) {
        objectAPI.assignedto(self, completionHandler: completionHandler)
    }

    public func `case`(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Case, ObjectAPI.GetError>) -> Void) {
        objectAPI.`case`(self, completionHandler: completionHandler)
    }

    public func milestone(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Milestone?, ObjectAPI.GetError>) -> Void) {
        objectAPI.milestone(self, completionHandler: completionHandler)
    }

    public func priority(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Priority, ObjectAPI.MatchError<SingleMatchError<Test.Id>, ObjectAPI.GetError>>) -> Void) {
        objectAPI.priority(self, completionHandler: completionHandler)
    }

    public func run(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Run, ObjectAPI.GetError>) -> Void) {
        objectAPI.run(self, completionHandler: completionHandler)
    }

    public func status(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Status, ObjectAPI.MatchError<SingleMatchError<Test.Id>, ObjectAPI.GetError>>) -> Void) {
        objectAPI.status(self, completionHandler: completionHandler)
    }

    public func template(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Template, ObjectAPI.MatchError<SingleMatchError<Test.Id>, ErrorContainer<ObjectAPI.GetError>>>) -> Void) {
        objectAPI.template(self, completionHandler: completionHandler)
    }

    public func type(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<CaseType, ObjectAPI.MatchError<SingleMatchError<Test.Id>, ObjectAPI.GetError>>) -> Void) {
        objectAPI.type(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension Test {

    enum JSONKeys: JSONKey {
        case assignedtoId = "assignedto_id"
        case caseId = "case_id"
        case estimate
        case estimateForecast = "estimate_forecast"
        case id
        case milestoneId = "milestone_id"
        case priorityId = "priority_id"
        case refs
        case runId = "run_id"
        case statusId = "status_id"
        case templateId = "template_id"
        case title
        case typeId = "type_id"
    }

}

// MARK: - Serialization

extension Test: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let caseId = json[JSONKeys.caseId.rawValue] as? Case.Id,
            let id = json[JSONKeys.id.rawValue] as? Id,
            let priorityId = json[JSONKeys.priorityId.rawValue] as? Priority.Id,
            let runId = json[JSONKeys.runId.rawValue] as? Run.Id,
            let statusId = json[JSONKeys.statusId.rawValue] as? Status.Id,
            let templateId = json[JSONKeys.templateId.rawValue] as? Template.Id,
            let title = json[JSONKeys.title.rawValue] as? String,
            let typeId = json[JSONKeys.typeId.rawValue] as? CaseType.Id else {
                return nil
        }

        let assignedtoId = json[JSONKeys.assignedtoId.rawValue] as? User.Id ?? nil
        let estimate = json[JSONKeys.estimate.rawValue] as? String ?? nil
        let estimateForecast = json[JSONKeys.estimateForecast.rawValue] as? String ?? nil
        let milestoneId = json[JSONKeys.milestoneId.rawValue] as? Milestone.Id ?? nil
        let refs = json[JSONKeys.refs.rawValue] as? String ?? nil

        let customFieldsContainer = CustomFieldsContainer(json: json)

        self.init(assignedtoId: assignedtoId, caseId: caseId, estimate: estimate, estimateForecast: estimateForecast, id: id, milestoneId: milestoneId, priorityId: priorityId, refs: refs, runId: runId, statusId: statusId, templateId: templateId, title: title, typeId: typeId, customFieldsContainer: customFieldsContainer)
    }

}

extension Test: JSONSerializable {

    private var serializedProperties: JSONDictionary {
        return [JSONKeys.assignedtoId.rawValue: assignedtoId as Any,
                JSONKeys.caseId.rawValue: caseId,
                JSONKeys.estimate.rawValue: estimate as Any,
                JSONKeys.estimateForecast.rawValue: estimateForecast as Any,
                JSONKeys.id.rawValue: id,
                JSONKeys.milestoneId.rawValue: milestoneId as Any,
                JSONKeys.priorityId.rawValue: priorityId,
                JSONKeys.refs.rawValue: refs as Any,
                JSONKeys.runId.rawValue: runId,
                JSONKeys.statusId.rawValue: statusId,
                JSONKeys.templateId.rawValue: templateId,
                JSONKeys.title.rawValue: title,
                JSONKeys.typeId.rawValue: typeId]
    }

    func serialized() -> JSONDictionary {
        var json = serializedProperties
        customFields.forEach { item in json[item.key] = item.value }
        return json
    }

}
