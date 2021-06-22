public struct Section: Identifiable, Equatable {
    public typealias Id = Int
    public let depth: Int
    public var description: String?
    public let displayOrder: Int
    public let id: Id
    public var name: String
    public let parentId: Id?
    public let suiteId: Suite.Id?
}

// MARK: - Foward Relationships (ObjectAPI)

extension Section {

    public func parent(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Section?, ObjectAPI.GetError>) -> Void) {
        objectAPI.parent(self, completionHandler: completionHandler)
    }

    public func suite(_ objectAPI: ObjectAPI, completionHandler: @escaping (Outcome<Suite?, ObjectAPI.GetError>) -> Void) {
        objectAPI.suite(self, completionHandler: completionHandler)
    }

}

// MARK: - JSON Keys

extension Section {

    enum JSONKeys: JSONKey {
        case depth
        case description
        case displayOrder = "display_order"
        case id
        case name
        case parentId = "parent_id"
        case suiteId = "suite_id"
    }

}

extension Section: UpdateRequestJSONKeys {

    var updateRequestJSONKeys: [JSONKey] {
        return [
            JSONKeys.description.rawValue,
            JSONKeys.name.rawValue
        ]
    }

}

// MARK: - Serialization

extension Section: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let depth = json[JSONKeys.depth.rawValue] as? Int,
            let displayOrder = json[JSONKeys.displayOrder.rawValue] as? Int,
            let id = json[JSONKeys.id.rawValue] as? Id,
            let name = json[JSONKeys.name.rawValue] as? String else {
                return nil
        }

        let description = json[JSONKeys.description.rawValue] as? String ?? nil
        let parentId = json[JSONKeys.parentId.rawValue] as? Id ?? nil
        let suiteId = json[JSONKeys.suiteId.rawValue] as? Suite.Id ?? nil

        self.init(depth: depth, description: description, displayOrder: displayOrder, id: id, name: name, parentId: parentId, suiteId: suiteId)
    }

}

extension Section: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.depth.rawValue: depth,
                JSONKeys.description.rawValue: description as Any,
                JSONKeys.displayOrder.rawValue: displayOrder,
                JSONKeys.id.rawValue: id,
                JSONKeys.name.rawValue: name,
                JSONKeys.parentId.rawValue: parentId as Any,
                JSONKeys.suiteId.rawValue: suiteId as Any]
    }

}

extension Section: UpdateRequestJSON { }
