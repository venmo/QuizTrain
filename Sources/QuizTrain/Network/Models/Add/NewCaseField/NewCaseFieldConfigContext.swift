// MARK: - Models

public struct NewCaseFieldConfigContext: Hashable {
    public var isGlobal: Bool
    public var projectIds: [Int]
}

// MARK: - Codable

extension NewCaseFieldConfigContext: Codable {
    enum CodingKeys: String, CodingKey {
        case isGlobal = "is_global"
        case projectIds = "project_ids"
    }
}
