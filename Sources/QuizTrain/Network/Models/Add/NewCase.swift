import Foundation

public struct NewCase: MutableCustomFields, Equatable {

    // MARK: Properties

    public var estimate: String?
    public var milestoneId: Milestone.Id?
    public var priorityId: Priority.Id?
    public var refs: String?
    public var templateId: Template.Id?
    public var title: String
    public var typeId: CaseType.Id?
    var customFieldsContainer = CustomFieldsContainer.empty()
    public var customFields: JSONDictionary {
        get { return self.customFieldsContainer.customFields }
        set { customFieldsContainer.customFields = newValue }
    }

    // MARK: Init

    public init(estimate: String? = nil, milestoneId: Milestone.Id? = nil, priorityId: Priority.Id? = nil, refs: String? = nil, templateId: Template.Id? = nil, title: String, typeId: CaseType.Id? = nil, customFields: JSONDictionary? = nil) {
        self.estimate = estimate
        self.milestoneId = milestoneId
        self.priorityId = priorityId
        self.refs = refs
        self.templateId = templateId
        self.title = title
        self.typeId = typeId
        if let customFields = customFields {
            customFieldsContainer.customFields = customFields
        }
    }

}

// MARK: - JSON Keys

extension NewCase {

    enum JSONKeys: JSONKey {
        case estimate
        case milestoneId = "milestone_id"
        case priorityId = "priority_id"
        case refs
        case templateId = "template_id"
        case title
        case typeId = "type_id"
    }

}

extension NewCase: AddRequestJSONKeys {

    var addRequestJSONKeys: [JSONKey] {
        var keys = [JSONKeys.estimate.rawValue,
                    JSONKeys.milestoneId.rawValue,
                    JSONKeys.priorityId.rawValue,
                    JSONKeys.refs.rawValue,
                    JSONKeys.templateId.rawValue,
                    JSONKeys.title.rawValue,
                    JSONKeys.typeId.rawValue]
        customFields.forEach { item in keys.append(item.key) }
        return keys
    }

}

// MARK: - Serialization

extension NewCase: JSONSerializable {

    private var serializedProperties: JSONDictionary {
        return [JSONKeys.estimate.rawValue: estimate as Any,
                JSONKeys.milestoneId.rawValue: milestoneId as Any,
                JSONKeys.priorityId.rawValue: priorityId as Any,
                JSONKeys.refs.rawValue: refs as Any,
                JSONKeys.templateId.rawValue: templateId as Any,
                JSONKeys.title.rawValue: title,
                JSONKeys.typeId.rawValue: typeId as Any]
    }

    func serialized() -> JSONDictionary {
        var json = serializedProperties
        customFields.forEach { item in json[item.key] = item.value }
        return json
    }

}

extension NewCase: AddRequestJSON { }
