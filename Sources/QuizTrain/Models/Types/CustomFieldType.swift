public enum CustomFieldType: Int, Equatable {
    case string = 1
    case integer = 2
    case text = 3
    case url = 4
    case checkbox = 5
    case dropdown = 6
    case user = 7
    case date = 8
    case milestone = 9
    case steps = 10
    case stepResults = 11
    case multiSelect = 12
}

extension CustomFieldType {

    // swiftlint:disable:next cyclomatic_complexity
    public func description() -> String {
        switch self {
        case .string:
            return "String" // String?
        case .integer:
            return "Integer" // Int?
        case .text:
            return "Text" // String?
        case .url:
            return "URL" // String? ("http://www.venmo.com/")
        case .checkbox:
            return "Checkbox" // Bool
        case .dropdown:
            return "Dropdown" // Int?
        case .user:
            return "User" // Int?
        case .date:
            return "Date" // String? ("10/17/2017")
        case .milestone:
            return "Milestone" // Int?
        case .steps:
            return "Steps" // String?
        case .stepResults:
            return "Step Results" // [[String: Any]] (unknown if this can be optional)
        case .multiSelect:
            return "Multi-Select" // [Int]
        }
    }

}
