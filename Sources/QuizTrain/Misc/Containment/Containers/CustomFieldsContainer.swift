/*
 Provides a container for TestRail custom fields which can be added to some
 objects. Enforces all custom fields to be prefixed with "custom_" (case
 sensitive) in their key. Prevents adding any "custom_*" entries matching
 omittedKeys. Any keys violating those rules will be silently omitted from being
 added to customFields.
 */
struct CustomFieldsContainer: JSONDeserializable, JSONSerializable, Equatable {

    // MARK: - Properties

    fileprivate var container: JSONDictionaryContainer

    public var customFields: JSONDictionary {
        get {
            return container.json
        }
        set {
            container.json = CustomFieldsContainer.filter(newValue, requiringKeyPrefix: CustomFieldsContainer.requiredKeyPrefix, omittingKeys: self.omittedKeys)
        }
    }

    // MARK: - JSONDeserializable

    init(json: JSONDictionary) {
        self.init(json: json, omittingKeys: [])
    }

    init(json: JSONDictionary, omittingKeys omittedKeys: [JSONKey]) {
        self.omittedKeys = omittedKeys
        container = JSONDictionaryContainer(json: CustomFieldsContainer.filter(json, requiringKeyPrefix: CustomFieldsContainer.requiredKeyPrefix, omittingKeys: omittedKeys))
    }

    // MARK: - JSONSerializable

    func serialized() -> JSONDictionary {
        return container.json
    }

    // MARK: - Filtering

    public let omittedKeys: [JSONKey]                                           // Keys which are omitted from customFields. This should contain any strongly-typed properties also prefixed with requiredKeyPrefix.
    private static let requiredKeyPrefix: JSONKey = "custom_"                   // All TestRail custom fields are prefixed with: "custom_"

    private static func filter(_ json: JSONDictionary, requiringKeyPrefix requiredKeyPrefix: String, omittingKeys omittedKeys: [JSONKey]) -> JSONDictionary {
        var jsonFiltered = json.filter { pair in pair.key.hasPrefix(requiredKeyPrefix) }
        jsonFiltered = jsonFiltered.filter { pair in !omittedKeys.contains(pair.key) }
        return jsonFiltered
    }

}

extension CustomFieldsContainer {

    public static func empty() -> CustomFieldsContainer {
        return CustomFieldsContainer(json: [:])
    }

}
