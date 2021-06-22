public struct Status: Identifiable, Equatable {
    public typealias Id = Int
    public let colorBright: Int
    public let colorDark: Int
    public let colorMedium: Int
    public let id: Id
    public let isFinal: Bool
    public let isSystem: Bool
    public let isUntested: Bool
    public let label: String
    public let name: String
}

// MARK: - JSON Keys

extension Status {

    enum JSONKeys: JSONKey {
        case colorBright = "color_bright"
        case colorDark = "color_dark"
        case colorMedium = "color_medium"
        case id
        case isFinal = "is_final"
        case isSystem = "is_system"
        case isUntested = "is_untested"
        case label
        case name
    }

}

// MARK: - Serialization

extension Status: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let colorBright = json[JSONKeys.colorBright.rawValue] as? Int,
            let colorDark = json[JSONKeys.colorDark.rawValue] as? Int,
            let colorMedium = json[JSONKeys.colorMedium.rawValue] as? Int,
            let id = json[JSONKeys.id.rawValue] as? Id,
            let isFinal = json[JSONKeys.isFinal.rawValue] as? Bool,
            let isSystem = json[JSONKeys.isSystem.rawValue] as? Bool,
            let isUntested = json[JSONKeys.isUntested.rawValue] as? Bool,
            let label = json[JSONKeys.label.rawValue] as? String,
            let name = json[JSONKeys.name.rawValue] as? String else {
                return nil
        }

        self.init(colorBright: colorBright, colorDark: colorDark, colorMedium: colorMedium, id: id, isFinal: isFinal, isSystem: isSystem, isUntested: isUntested, label: label, name: name)
    }

}

extension Status: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.colorBright.rawValue: colorBright,
                JSONKeys.colorDark.rawValue: colorDark,
                JSONKeys.colorMedium.rawValue: colorMedium,
                JSONKeys.id.rawValue: id,
                JSONKeys.isFinal.rawValue: isFinal,
                JSONKeys.isSystem.rawValue: isSystem,
                JSONKeys.isUntested.rawValue: isUntested,
                JSONKeys.label.rawValue: label,
                JSONKeys.name.rawValue: name]
    }

}
