import Foundation

public struct CaseField: Identifiable, Equatable {
    public typealias Id = Int
    public let configs: [Config]
    public let description: String?
    public let displayOrder: Int
    public let id: Id
    public let includeAll: Bool
    public let isActive: Bool
    public let label: String
    public let name: String
    public let systemName: String
    public let templateIds: [Template.Id]
    public let typeId: CustomFieldType
}

// MARK: - Foward Relationships (ObjectAPI)

extension CaseField {

    public func templates(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<[Template], ObjectAPI.MatchError<MultipleMatchError<Template, Template.Id>, ErrorContainer<ObjectAPI.GetError>>>) -> Void) {
        objectAPI.templates(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension CaseField {

    enum JSONKeys: JSONKey {
        case configs
        case description
        case displayOrder = "display_order"
        case id
        case includeAll = "include_all"
        case isActive = "is_active"
        case label
        case name
        case systemName = "system_name"
        case templateIds = "template_ids"
        case typeId = "type_id"
    }

}

// MARK: - Serialization

extension CaseField: JSONDeserializable {

    init?(json: JSONDictionary) {

        /*
         The formatting of JSONKeys.configs returned by the API differs:

         - Get requests return a [JSONDictionary].
         - Add requests return a String which can be converted into a
           [JSONDictionary].
         */
        let configsJson: [JSONDictionary]
        if let jsonArray = json[JSONKeys.configs.rawValue] as? [JSONDictionary] {
            configsJson = jsonArray
        } else if let jsonString = json[JSONKeys.configs.rawValue] as? String {
            do {
                guard let data = jsonString.data(using: .utf8) else { return nil }
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [JSONDictionary] else { return nil }
                configsJson = jsonObject
            } catch {
                return nil
            }
        } else {
            return nil
        }

        guard let configs: [Config] = CaseField.deserialized(configsJson),
            let displayOrder = json[JSONKeys.displayOrder.rawValue] as? Int,
            let id = json[JSONKeys.id.rawValue] as? Id,
            let includeAll = json[JSONKeys.includeAll.rawValue] as? Bool,
            let isActive = json[JSONKeys.isActive.rawValue] as? Bool,
            let label = json[JSONKeys.label.rawValue] as? String,
            let name = json[JSONKeys.name.rawValue] as? String,
            let systemName = json[JSONKeys.systemName.rawValue] as? String,
            let templateIds = json[JSONKeys.templateIds.rawValue] as? [Template.Id],
            let typeIdInt = json[JSONKeys.typeId.rawValue] as? Int,
            let typeId = CustomFieldType(rawValue: typeIdInt) else {
                return nil
        }

        let description = json[JSONKeys.description.rawValue] as? String ?? nil

        self.init(configs: configs, description: description, displayOrder: displayOrder, id: id, includeAll: includeAll, isActive: isActive, label: label, name: name, systemName: systemName, templateIds: templateIds, typeId: typeId)
    }

}

extension CaseField: JSONSerializable {

    func serialized() -> JSONDictionary {

        let configsSerialized: [JSONDictionary] = Config.serialized(configs)

        return [JSONKeys.configs.rawValue: configsSerialized,
                JSONKeys.description.rawValue: description as Any,
                JSONKeys.displayOrder.rawValue: displayOrder,
                JSONKeys.id.rawValue: id,
                JSONKeys.includeAll.rawValue: includeAll,
                JSONKeys.isActive.rawValue: isActive,
                JSONKeys.label.rawValue: label,
                JSONKeys.name.rawValue: name,
                JSONKeys.systemName.rawValue: systemName,
                JSONKeys.templateIds.rawValue: templateIds,
                JSONKeys.typeId.rawValue: typeId.rawValue]
    }

}
