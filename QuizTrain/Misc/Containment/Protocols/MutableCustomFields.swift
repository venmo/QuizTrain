/*
 Provides read-write CustomField support.
 */
protocol MutableCustomFields: CustomFields {
    var customFields: JSONDictionary { get set }
    var customFieldsContainer: CustomFieldsContainer { get set }
}

extension MutableCustomFields {
    public var customFields: JSONDictionary {
        get {
            return self.customFieldsContainer.customFields
        }
        set {
            customFieldsContainer.customFields = newValue
        }
    }
}
