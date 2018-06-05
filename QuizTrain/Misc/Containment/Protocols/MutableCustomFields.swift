/*
 Provides read-write CustomField support.
 */
public protocol MutableCustomFields: CustomFields {
    var customFields: JSONDictionary { get set }
}
