@testable import QuizTrain

protocol CustomFieldsDataProvider {

    // Valid

    var customFields: JSONDictionary { get }
    var customFieldsContainer: CustomFieldsContainer { get }
    var customFieldsKeys: [JSONKey] { get }
    static var customFields: JSONDictionary { get }
    static var customFieldsContainer: CustomFieldsContainer { get }
    static var customFieldsKeys: [JSONKey] { get }

    // Empty

    var emptyCustomFields: JSONDictionary { get }
    var emptyCustomFieldsContainer: CustomFieldsContainer { get }
    static var emptyCustomFields: JSONDictionary { get }
    static var emptyCustomFieldsContainer: CustomFieldsContainer { get }

    // Invalid

    var invalidCustomFields: JSONDictionary { get }
    var invalidCustomFieldsKeys: [JSONKey] { get }
    static var invalidCustomFields: JSONDictionary { get }
    static var invalidCustomFieldsKeys: [JSONKey] { get }

    // Valid/Invalid

    var validAndInvalidCustomFields: JSONDictionary { get }
    var validAndInvalidCustomFieldsKeys: [JSONKey] { get }
    static var validAndInvalidCustomFields: JSONDictionary { get }
    static var validAndInvalidCustomFieldsKeys: [JSONKey] { get }
}

// MARK: - Valid

extension CustomFieldsDataProvider {

    var customFields: JSONDictionary {
        return Self.customFields
    }

    var customFieldsContainer: CustomFieldsContainer {
        return Self.customFieldsContainer
    }

    var customFieldsKeys: [JSONKey] {
        return Self.customFieldsKeys
    }

    static var customFields: JSONDictionary {
        return [
            "custom_field_0": -587,
            "custom_field_1": "What is the meaning of life?",
            "custom_field_2": 3.14159,
            "custom_field_3": ["Hello": ["🐹🐹🐹", 4.32, true, 789]]
        ]
    }

    static var customFieldsContainer: CustomFieldsContainer {
        return CustomFieldsContainer(json: customFields)
    }

    static var customFieldsKeys: [JSONKey] {
        return Self.customFields.map { $0.key }
    }

}

// MARK: - Empty

extension CustomFieldsDataProvider {

    var emptyCustomFields: JSONDictionary {
        return Self.emptyCustomFields
    }

    var emptyCustomFieldsContainer: CustomFieldsContainer {
        return Self.emptyCustomFieldsContainer
    }

    static var emptyCustomFields: JSONDictionary {
        return [:]
    }

    static var emptyCustomFieldsContainer: CustomFieldsContainer {
        return CustomFieldsContainer(json: [:])
    }

}

// MARK: - Invalid

extension CustomFieldsDataProvider {

    var invalidCustomFields: JSONDictionary {
        return Self.invalidCustomFields
    }

    var invalidCustomFieldsKeys: [JSONKey] {
        return Self.invalidCustomFieldsKeys
    }

    static var invalidCustomFields: JSONDictionary {
        return ["_custom_field": "Invalid",
                "customField": "Invalid",
                "this_custom_field": "is also invalid",
                "Custom_field": "Invalid",
                " custom_field": ["😀😀😀": 3.14]]
    }

    static var invalidCustomFieldsKeys: [JSONKey] {
        return Self.invalidCustomFields.map { $0.key }
    }

}

// MARK: - Valid/Invalid

extension CustomFieldsDataProvider {

    var validAndInvalidCustomFields: JSONDictionary {
        return Self.validAndInvalidCustomFields
    }

    var validAndInvalidCustomFieldsKeys: [JSONKey] {
        return Self.validAndInvalidCustomFieldsKeys
    }

    static var validAndInvalidCustomFields: JSONDictionary {
        var dict = CustomFieldsContainerTests.customFields
        CustomFieldsContainerTests.invalidCustomFields.forEach { item in dict[item.key] = item.value }
        return dict
    }

    static var validAndInvalidCustomFieldsKeys: [JSONKey] {
        return Self.validAndInvalidCustomFields.map { $0.key }
    }

}
