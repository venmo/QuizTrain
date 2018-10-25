// MARK: - Protocols

public protocol NewCaseFieldData: Codable, Hashable {
    associatedtype Configs: NewCaseFieldConfig
    var type: NewCaseFieldType { get }
    var configs: [Configs] { get }
}

// MARK: - Models

public struct NewCaseFieldStringData: NewCaseFieldData {
    public let type = NewCaseFieldType.string
    public var configs: [NewCaseFieldStringConfig]
}

public struct NewCaseFieldIntegerData: NewCaseFieldData {
    public let type = NewCaseFieldType.integer
    public var configs: [NewCaseFieldIntegerConfig]
}

public struct NewCaseFieldTextData: NewCaseFieldData {
    public let type = NewCaseFieldType.text
    public var configs: [NewCaseFieldTextConfig]
}

public struct NewCaseFieldURLData: NewCaseFieldData {
    public let type = NewCaseFieldType.url
    public var configs: [NewCaseFieldURLConfig]
}

public struct NewCaseFieldCheckboxData: NewCaseFieldData {
    public let type = NewCaseFieldType.checkbox
    public var configs: [NewCaseFieldCheckboxConfig]
}

public struct NewCaseFieldDropdownData: NewCaseFieldData {
    public let type = NewCaseFieldType.dropdown
    public var configs: [NewCaseFieldDropdownConfig]
}

public struct NewCaseFieldUserData: NewCaseFieldData {
    public let type = NewCaseFieldType.user
    public var configs: [NewCaseFieldUserConfig]
}

public struct NewCaseFieldDateData: NewCaseFieldData {
    public let type = NewCaseFieldType.date
    public var configs: [NewCaseFieldDateConfig]
}

public struct NewCaseFieldMilestoneData: NewCaseFieldData {
    public let type = NewCaseFieldType.milestone
    public var configs: [NewCaseFieldMilestoneConfig]
}

public struct NewCaseFieldStepsData: NewCaseFieldData {
    public let type = NewCaseFieldType.steps
    public var configs: [NewCaseFieldStepsConfig]
}

public struct NewCaseFieldMultiselectData: NewCaseFieldData {
    public let type = NewCaseFieldType.multiselect
    public var configs: [NewCaseFieldMultiselectConfig]
}
