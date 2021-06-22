public enum NewCaseFieldType: String, Codable, Hashable {
    case string
    case integer
    case text
    case url
    case checkbox
    case dropdown
    case user
    case date
    case milestone
    case steps
    case multiselect
}

extension NewCaseFieldType {

    static func==(lhs: CustomFieldType, rhs: NewCaseFieldType) -> Bool {
        return rhs == lhs
    }

    // swiftlint:disable:next cyclomatic_complexity
    static func==(lhs: NewCaseFieldType, rhs: CustomFieldType) -> Bool {
        switch lhs {
        case .string:
            return rhs == CustomFieldType.string
        case .integer:
            return rhs == CustomFieldType.integer
        case .text:
            return rhs == CustomFieldType.text
        case .url:
            return rhs == CustomFieldType.url
        case .checkbox:
            return rhs == CustomFieldType.checkbox
        case .dropdown:
            return rhs == CustomFieldType.dropdown
        case .user:
            return rhs == CustomFieldType.user
        case .date:
            return rhs == CustomFieldType.date
        case .milestone:
            return rhs == CustomFieldType.milestone
        case .steps:
            return rhs == CustomFieldType.steps
        case .multiselect:
            return rhs == CustomFieldType.multiSelect
        }
    }

}
