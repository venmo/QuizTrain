// MARK: - Protocols

public protocol NewCaseFieldConfig: Codable, Hashable {
    associatedtype Options
    var context: NewCaseFieldConfigContext { get }
    var options: Options { get }
}

// MARK: - Models

public struct NewCaseFieldStringConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigStringOptions
}

public struct NewCaseFieldIntegerConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigIntegerOptions
}

public struct NewCaseFieldTextConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigTextOptions
}

public struct NewCaseFieldURLConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigURLOptions
}

public struct NewCaseFieldCheckboxConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigCheckboxOptions
}

public struct NewCaseFieldDropdownConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigDropdownOptions
}

public struct NewCaseFieldUserConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigUserOptions
}

public struct NewCaseFieldDateConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigDateOptions
}

public struct NewCaseFieldMilestoneConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigMilestoneOptions
}

public struct NewCaseFieldStepsConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigStepsOptions
}

public struct NewCaseFieldMultiselectConfig: NewCaseFieldConfig {
    public var context: NewCaseFieldConfigContext
    public var options: NewCaseFieldConfigMultiselectOptions
}
