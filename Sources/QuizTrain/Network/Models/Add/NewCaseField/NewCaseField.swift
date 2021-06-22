import Foundation

// MARK: - Models

public struct NewCaseField<DataType: NewCaseFieldData>: Hashable {

    public var configs: [DataType.Configs] { return data.configs }
    public var data: DataType
    public var description: String?
    public var label: String
    public var name: String
    public var includeAll: Bool
    public var templateIds: [Int]
    public var type: NewCaseFieldType { return data.type }

    fileprivate init(data: DataType, description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = []) {
        self.data = data
        self.description = description
        self.includeAll = includeAll
        self.label = label
        self.name = name
        self.templateIds = templateIds
    }

}

// MARK: - Initializers

extension NewCaseField where DataType == NewCaseFieldStringData {

    /**
     Initializes a new string CaseField. Pass this to ObjectAPI's addCaseField()
     to create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
       - defaultValue: Optional default value of this case field.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool, defaultValue: String? = nil) {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = NewCaseFieldConfigStringOptions(isRequired: isRequired, defaultValue: defaultValue)
        let config = NewCaseFieldStringConfig(context: context, options: options)
        let data = NewCaseFieldStringData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldIntegerData {

    /**
     Initializes a new integer CaseField. Pass this to ObjectAPI's
     addCaseField() to create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
       - defaultValue: Optional default value of this case field.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool, defaultValue: Int? = nil) {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = NewCaseFieldConfigIntegerOptions(isRequired: isRequired, defaultValue: defaultValue)
        let config = NewCaseFieldIntegerConfig(context: context, options: options)
        let data = NewCaseFieldIntegerData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldTextData {

    /**
     Initializes a new text CaseField. Pass this to ObjectAPI's addCaseField()
     to create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
       - defaultValue: Optional default value of this case field.
       - format: Text format allowed for this case field. Pass either .plain or .markdown.
       - rows: Maximum number of lines of text allowed for this case field.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool, defaultValue: String? = nil, format: NewCaseFieldConfigTextOptions.Format, rows: NewCaseFieldConfigTextOptions.Rows) {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = NewCaseFieldConfigTextOptions(isRequired: isRequired, defaultValue: defaultValue, format: format, rows: rows)
        let config = NewCaseFieldTextConfig(context: context, options: options)
        let data = NewCaseFieldTextData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldURLData {

    /**
     Initializes a new URL CaseField. Pass this to ObjectAPI's addCaseField() to
     create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
       - defaultValue: Optional default value of this case field.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool, defaultValue: URL? = nil) {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = NewCaseFieldConfigURLOptions(isRequired: isRequired, defaultValue: defaultValue)
        let config = NewCaseFieldURLConfig(context: context, options: options)
        let data = NewCaseFieldURLData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldCheckboxData {

    /**
     Initializes a new checkbox CaseField. Pass this to ObjectAPI's
     addCaseField() to create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
       - defaultValue: Required default value of this case field. True means checked, false means unchecked.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool, defaultValue: Bool) {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = NewCaseFieldConfigCheckboxOptions(isRequired: isRequired, defaultValue: defaultValue)
        let config = NewCaseFieldCheckboxConfig(context: context, options: options)
        let data = NewCaseFieldCheckboxData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldDropdownData {

    /**
     Initializes a new dropdown CaseField. Pass this to ObjectAPI's
     addCaseField() to create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
       - items: Required list of 1+ selectable items which will appear in the dropdown. This will throw an error if you pass an empty list.
       - defaultValue: Required index of default item to use from |items|. This will throw an error if you pass an invalid index.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool, items: [NewCaseFieldConfigDropdownOptions.Item], defaultValue: Int) throws {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = try NewCaseFieldConfigDropdownOptions(items: items, isRequired: isRequired, defaultValue: defaultValue) // Throws if `defaultValue` is out of bounds of `items` or if `items` is empty.
        let config = NewCaseFieldDropdownConfig(context: context, options: options)
        let data = NewCaseFieldDropdownData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldUserData {

    /**
     Initializes a new user CaseField. Pass this to ObjectAPI's addCaseField()
     to create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
       - defaultValue: Optional default value of this case field. If passed this must match a valid User.Id.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool, defaultValue: Int? = nil) {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = NewCaseFieldConfigUserOptions(isRequired: isRequired, defaultValue: defaultValue)
        let config = NewCaseFieldUserConfig(context: context, options: options)
        let data = NewCaseFieldUserData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldDateData {

    /**
     Initializes a new date CaseField. Pass this to ObjectAPI's addCaseField()
     to create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool) {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = NewCaseFieldConfigDateOptions(isRequired: isRequired)
        let config = NewCaseFieldDateConfig(context: context, options: options)
        let data = NewCaseFieldDateData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldMilestoneData {

    /**
     Initializes a new milestone CaseField. Pass this to ObjectAPI's
     addCaseField() to create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool) {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = NewCaseFieldConfigMilestoneOptions(isRequired: isRequired)
        let config = NewCaseFieldMilestoneConfig(context: context, options: options)
        let data = NewCaseFieldMilestoneData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldStepsData {

    /**
     Initializes a new steps CaseField. Pass this to ObjectAPI's addCaseField()
     to create it on your TestRail instance.

     TestRail limits you to no more than on steps CaseField across your entire
     instance. If you attempt to create a second a 400 error will be returned by
     the API.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
       - format: Text format allowed to be used in each step for this case field. Pass either .plain or .markdown.
       - hasExpected: Pass true to add a separate expected result field for each step.
       - rows: Maximum number of steps allowed for this case field.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool, format: NewCaseFieldConfigStepsOptions.Format, hasExpected: Bool, rows: NewCaseFieldConfigStepsOptions.Rows) {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = NewCaseFieldConfigStepsOptions(isRequired: isRequired, format: format, hasExpected: hasExpected, rows: rows)
        let config = NewCaseFieldStepsConfig(context: context, options: options)
        let data = NewCaseFieldStepsData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

extension NewCaseField where DataType == NewCaseFieldMultiselectData {

    /**
     Initializes a new multiselect CaseField. Pass this to ObjectAPI's
     addCaseField() to create it on your TestRail instance.

     - parameters:
       - description: Optional description.
       - label: Human readable name of this case field.
       - name: System name of case field. Lowercase letters a...z and _ only. Do not prefix with "custom_". Must be unique across your TestRail instance.
       - includeAll: True applies this case field to all templates. Pass false to specify specific templateIds.
       - templateIds: Applies this case field only to these templates. You must set includeAll to false if you specify specific templateIds.
       - isGlobal: True applies to all projects. Pass false to specify specific projectIds.
       - projectIds: Applies this case field only to these projects. You must set isGlobal to false if you specify specific projectIds.
       - isRequired: True means this case field must be filled out when creating new cases to which this case field applies.
       - items: Required list of 1+ selectable items which will appear as multiselect options. This will throw an error if you pass an empty list.
     */
    public init(description: String? = nil, label: String, name: String, includeAll: Bool, templateIds: [Int] = [], isGlobal: Bool, projectIds: [Int] = [], isRequired: Bool, items: [NewCaseFieldConfigMultiselectOptions.Item]) throws {
        let context = NewCaseFieldConfigContext(isGlobal: isGlobal, projectIds: projectIds)
        let options = try NewCaseFieldConfigMultiselectOptions(items: items, isRequired: isRequired) // Throws if `items` is empty.
        let config = NewCaseFieldMultiselectConfig(context: context, options: options)
        let data = NewCaseFieldMultiselectData(configs: [config])
        self.init(data: data, description: description, label: label, name: name, includeAll: includeAll, templateIds: templateIds)
    }

}

// MARK: - Codable

extension NewCaseField: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case configs
        case description
        case includeAll = "include_all"
        case label
        case name
        case templateIds = "template_ids"
        case type
    }

    // swiftlint:disable:next cyclomatic_complexity
    public init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: CodingKeys.self)

        description = try values.decodeIfPresent(String.self, forKey: .description)
        includeAll = try values.decode(Bool.self, forKey: .includeAll)
        label = try values.decode(String.self, forKey: .label)
        name = try values.decode(String.self, forKey: .name)
        templateIds = try values.decode([Int].self, forKey: .templateIds)

        let type = try values.decode(NewCaseFieldType.self, forKey: .type)
        switch type {
        case .string:
            let configs = try values.decode([NewCaseFieldStringConfig].self, forKey: .configs)
            data = NewCaseFieldStringData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .integer:
            let configs = try values.decode([NewCaseFieldIntegerConfig].self, forKey: .configs)
            data = NewCaseFieldIntegerData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .text:
            let configs = try values.decode([NewCaseFieldTextConfig].self, forKey: .configs)
            data = NewCaseFieldTextData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .url:
            let configs = try values.decode([NewCaseFieldURLConfig].self, forKey: .configs)
            data = NewCaseFieldURLData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .checkbox:
            let configs = try values.decode([NewCaseFieldCheckboxConfig].self, forKey: .configs)
            data = NewCaseFieldCheckboxData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .dropdown:
            let configs = try values.decode([NewCaseFieldDropdownConfig].self, forKey: .configs)
            data = NewCaseFieldDropdownData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .user:
            let configs = try values.decode([NewCaseFieldUserConfig].self, forKey: .configs)
            data = NewCaseFieldUserData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .date:
            let configs = try values.decode([NewCaseFieldDateConfig].self, forKey: .configs)
            data = NewCaseFieldDateData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .milestone:
            let configs = try values.decode([NewCaseFieldMilestoneConfig].self, forKey: .configs)
            data = NewCaseFieldMilestoneData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .steps:
            let configs = try values.decode([NewCaseFieldStepsConfig].self, forKey: .configs)
            data = NewCaseFieldStepsData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        case .multiselect:
            let configs = try values.decode([NewCaseFieldMultiselectConfig].self, forKey: .configs)
            data = NewCaseFieldMultiselectData(configs: configs) as! DataType // swiftlint:disable:this force_cast
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(configs, forKey: .configs)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(includeAll, forKey: .includeAll)
        try container.encode(label, forKey: .label)
        try container.encode(name, forKey: .name)
        try container.encode(templateIds, forKey: .templateIds)
        try container.encode(type, forKey: .type)
    }

}

// MARK: - AddRequestJSONKeys | JSONSerializable | AddRequestJSON

extension NewCaseField: AddRequestJSONKeys {
    var addRequestJSONKeys: [JSONKey] {
        return CodingKeys.allCases.map { $0.rawValue }
    }
}

extension NewCaseField: JSONSerializable {
    func serialized() -> JSONDictionary {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(self) // swiftlint:disable:this force_try
        let dict = try! JSONSerialization.jsonObject(with: data) as! JSONDictionary // swiftlint:disable:this force_try force_cast
        return dict
    }
}

extension NewCaseField: AddRequestJSON { }
