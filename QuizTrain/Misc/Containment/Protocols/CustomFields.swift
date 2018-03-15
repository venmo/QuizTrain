/*
 Provides read-only CustomField support.
 */
protocol CustomFields {
    var customFields: JSONDictionary { get }
    var customFieldsContainer: CustomFieldsContainer { get }
}

extension CustomFields {
    public var customFields: JSONDictionary {
        return self.customFieldsContainer.customFields
    }
}
