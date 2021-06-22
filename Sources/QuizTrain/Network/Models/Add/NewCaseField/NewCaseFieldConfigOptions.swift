import Foundation

// MARK: - Models

public struct NewCaseFieldConfigStringOptions: Hashable {
    public var isRequired: Bool
    public var defaultValue: String?
}

public struct NewCaseFieldConfigIntegerOptions: Hashable {
    public var isRequired: Bool
    public var defaultValue: Int?
}

public struct NewCaseFieldConfigTextOptions: Hashable {

    public var isRequired: Bool
    public var defaultValue: String?
    public var format: Format
    public var rows: Rows

    public enum Format: String, Codable, Hashable {
        case plain
        case markdown
    }

    public enum Rows: String, Codable, Hashable {
        case unspecified = ""
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case ten = "10"
    }
}

public struct NewCaseFieldConfigURLOptions: Hashable {
    public var isRequired: Bool
    public var defaultValue: URL?
}

public struct NewCaseFieldConfigCheckboxOptions: Hashable {
    public var isRequired: Bool
    public var defaultValue: Bool
}

public struct NewCaseFieldConfigDropdownOptions: Hashable {

    public typealias Item = String

    private var _items: [Item]
    private var _defaultValue: Int

    public var items: [Item] { return _items }
    public var isRequired: Bool
    public var defaultValue: Int { return _defaultValue } // A valid index in .items.

    public enum DefaultValueError: Error {
        case defaultValueOutOfRange
        case itemsCannotBeEmpty
    }

    public init(items: [Item], isRequired: Bool, defaultValue: Int) throws {
        self.isRequired = isRequired
        _items = []; _defaultValue = 0
        try set(items: items, withDefaultValue: defaultValue)
    }

    /***
     Sets .items and .defaultValue properties. Enforces that |items| is not
     empty and |defaultValue| is a valid index in |items|.
     */
    public mutating func set(items: [Item], withDefaultValue defaultValue: Int) throws {
        guard !items.isEmpty else {
            throw DefaultValueError.itemsCannotBeEmpty
        }
        guard items.count > defaultValue else {
            throw DefaultValueError.defaultValueOutOfRange
        }
        _items = items
        _defaultValue = defaultValue
    }
}

public struct NewCaseFieldConfigUserOptions: Hashable {
    public var isRequired: Bool
    public var defaultValue: Int? // User.Id
}

public struct NewCaseFieldConfigDateOptions: Hashable {
    public var isRequired: Bool
}

public struct NewCaseFieldConfigMilestoneOptions: Hashable {
    public var isRequired: Bool
}

public struct NewCaseFieldConfigStepsOptions: Hashable {

    public var isRequired: Bool
    public var format: Format
    public var hasExpected: Bool // true means "Use a separate Expected Result field for each step"
    public var rows: Rows

    public enum Format: String, Codable, Hashable {
        case plain
        case markdown
    }

    public enum Rows: String, Codable, Hashable {
        case unspecified = ""
        case three = "3"
        case four = "4"
        case five = "5"
        case six = "6"
        case seven = "7"
        case eight = "8"
        case nine = "9"
        case ten = "10"
    }
}

public struct NewCaseFieldConfigMultiselectOptions: Hashable {

    public typealias Item = String
    private var _items: [Item]
    public var items: [Item] { return _items }
    public var isRequired: Bool

    public init(items: [Item], isRequired: Bool) throws {
        self.isRequired = isRequired
        _items = []
        try set(items: items)
    }

    public enum DefaultValueError: Error {
        case itemsCannotBeEmpty
    }

    /***
     Sets .items property enforcing it's not empty.
     */
    public mutating func set(items: [Item]) throws {
        guard !items.isEmpty else {
            throw DefaultValueError.itemsCannotBeEmpty
        }
        _items = items
    }
}

// MARK: - Codable

extension NewCaseFieldConfigStringOptions: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case isRequired = "is_required"
        case defaultValue = "default_value"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isRequired = try values.decode(Bool.self, forKey: .isRequired)
        let defaultValue = try values.decode(String.self, forKey: .defaultValue)
        self.defaultValue = defaultValue.isEmpty ? nil : defaultValue
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encode(defaultValue ?? "", forKey: .defaultValue)
    }

}

extension NewCaseFieldConfigIntegerOptions: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case isRequired = "is_required"
        case defaultValue = "default_value"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isRequired = try values.decode(Bool.self, forKey: .isRequired)
        let defaultValue = try values.decode(String.self, forKey: .defaultValue)
        self.defaultValue = defaultValue.isEmpty ? nil : Int(defaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRequired, forKey: .isRequired)
        let defaultValue: String
        if let integer = self.defaultValue {
            defaultValue = String(integer)
        } else {
            defaultValue = ""
        }
        try container.encode(defaultValue, forKey: .defaultValue)
    }

}

extension NewCaseFieldConfigTextOptions: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case isRequired = "is_required"
        case defaultValue = "default_value"
        case format
        case rows
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isRequired = try values.decode(Bool.self, forKey: .isRequired)
        let defaultValue = try values.decode(String.self, forKey: .defaultValue)
        self.defaultValue = defaultValue.isEmpty ? nil : defaultValue
        format = try values.decode(Format.self, forKey: .format)
        rows = try values.decode(Rows.self, forKey: .rows)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encode(defaultValue ?? "", forKey: .defaultValue)
        try container.encode(format, forKey: .format)
        try container.encode(rows, forKey: .rows)
    }

}

extension NewCaseFieldConfigURLOptions: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case isRequired = "is_required"
        case defaultValue = "default_value"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isRequired = try values.decode(Bool.self, forKey: .isRequired)
        let defaultValue = try values.decode(String.self, forKey: .defaultValue)
        self.defaultValue = URL(string: defaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRequired, forKey: .isRequired)
        let defaultValue: String
        if let url = self.defaultValue {
            defaultValue = url.absoluteString
        } else {
            defaultValue = ""
        }
        try container.encode(defaultValue, forKey: .defaultValue)
    }

}

extension NewCaseFieldConfigCheckboxOptions: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case isRequired = "is_required"
        case defaultValue = "default_value"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isRequired = try values.decode(Bool.self, forKey: .isRequired)
        let defaultValue = try values.decode(String.self, forKey: .defaultValue)
        switch defaultValue.lowercased() {
        case "0", "false":
            self.defaultValue = false
        case "1", "true":
            self.defaultValue = true
        default:
            throw DecodingError.dataCorruptedError(forKey: .defaultValue, in: values, debugDescription: "Invalid value: \(defaultValue)")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encode(String(defaultValue), forKey: .defaultValue)
    }

}

extension NewCaseFieldConfigDropdownOptions: Codable, ItemsConverter {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case items
        case isRequired = "is_required"
        case defaultValue = "default_value"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let isRequired = try values.decode(Bool.self, forKey: .isRequired)
        let itemsString = try values.decode(String.self, forKey: .items)
        guard let items = NewCaseFieldConfigDropdownOptions.items(from: itemsString) else {
            throw DecodingError.dataCorruptedError(forKey: .items, in: values, debugDescription: "Invalid value: \(itemsString)")
        }
        let defaultValueString = try values.decode(String.self, forKey: .defaultValue)
        guard var defaultValue = Int(defaultValueString) else {
            throw DecodingError.dataCorruptedError(forKey: .defaultValue, in: values, debugDescription: "Invalid value: \(defaultValueString)")
        }
        defaultValue -= 1 // 1 indexed to 0 indexed
        try self.init(items: items, isRequired: isRequired, defaultValue: defaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encode(NewCaseFieldConfigDropdownOptions.string(from: items), forKey: .items)
        let defaultValue = String(self.defaultValue + 1) // 0 indexed to 1 indexed.
        try container.encode(defaultValue, forKey: .defaultValue)
    }

}

extension NewCaseFieldConfigUserOptions: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case isRequired = "is_required"
        case defaultValue = "default_value"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isRequired = try values.decode(Bool.self, forKey: .isRequired)
        let defaultValue = try values.decode(String.self, forKey: .defaultValue)
        self.defaultValue = defaultValue.isEmpty ? nil : Int(defaultValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRequired, forKey: .isRequired)
        let defaultValue: String
        if let integer = self.defaultValue {
            defaultValue = String(integer)
        } else {
            defaultValue = ""
        }
        try container.encode(defaultValue, forKey: .defaultValue)
    }

}

extension NewCaseFieldConfigDateOptions: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case isRequired = "is_required"
    }

}

extension NewCaseFieldConfigMilestoneOptions: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case isRequired = "is_required"
    }

}

extension NewCaseFieldConfigStepsOptions: Codable {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case isRequired = "is_required"
        case format
        case hasExpected = "has_expected"
        case rows
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        isRequired = try values.decode(Bool.self, forKey: .isRequired)
        format = try values.decode(Format.self, forKey: .format)
        hasExpected = try values.decode(Bool.self, forKey: .hasExpected)
        rows = try values.decode(Rows.self, forKey: .rows)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encode(hasExpected, forKey: .hasExpected)
        try container.encode(format, forKey: .format)
        try container.encode(rows, forKey: .rows)
    }

}

extension NewCaseFieldConfigMultiselectOptions: Codable, ItemsConverter {

    fileprivate enum CodingKeys: String, CodingKey, CaseIterable {
        case items
        case isRequired = "is_required"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let isRequired = try values.decode(Bool.self, forKey: .isRequired)
        let itemsString = try values.decode(String.self, forKey: .items)
        guard let items = NewCaseFieldConfigMultiselectOptions.items(from: itemsString) else {
            throw DecodingError.dataCorruptedError(forKey: .items, in: values, debugDescription: "Invalid value: \(itemsString)")
        }
        try self.init(items: items, isRequired: isRequired)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isRequired, forKey: .isRequired)
        try container.encode(NewCaseFieldConfigMultiselectOptions.string(from: items), forKey: .items)
    }

}

// MARK: - Items

protocol ItemsConverter {
    associatedtype Item
    static func string(from items: [Item]) -> String
    static func items(from string: String) -> [Item]?
}

extension ItemsConverter where Self.Item == String {

    /// ["One", "Two", "Three"] ---> "1, One\n2, Two\n3, Three"
    static func string(from items: [Item]) -> String {
        var itemsString = ""
        for i in 0..<items.count {
            if !itemsString.isEmpty {
                itemsString += "\n"
            }
            let itemString = "\(String(i + 1)), \(items[i])"
            itemsString.append(itemString)
        }
        return itemsString
    }

    /// "1, One\n2, Two\n3, Three" ---> ["One", "Two", "Three"]
    static func items(from string: String) -> [Item]? {
        let stringSplit = string.split(separator: "\n")
        var items = [Item]()
        for i in 0..<stringSplit.count {
            let itemString = stringSplit[i]
            let number = i + 1
            guard let range = itemString.range(of: "\(number), ") else {
                return nil
            }
            let item = itemString.replacingCharacters(in: range, with: "")
            items.append(Item(item))
        }
        return items
    }

}
