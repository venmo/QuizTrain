extension Project {
    public enum SuiteMode: Int, Equatable {
        case singleSuite = 1
        case singleSuitePlusBaselines = 2
        case multipleSuites = 3
    }
}

extension Project.SuiteMode {
    public func description() -> String {
        switch self {
        case .singleSuite:
            return "Single Suite"
        case .singleSuitePlusBaselines:
            return "Single Suite Plus Baselines"
        case .multipleSuites:
            return "Multiple Suites"
        }
    }
}
