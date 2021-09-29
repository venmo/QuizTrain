public struct BulkSections {
    public let offset: Int
    public let limit: Int
    public let size: Int
    public let sections: [Section]
    public let _links: Links
}

// MARK: - JSON Keys

extension BulkSections {

    enum JSONKeys: JSONKey {
        case offset = "offset"
        case limit = "limit"
        case size = "size"
        case _links = "_links"
        case sections = "sections"
        case next = "next"
        case prev = "prev"
    }

}

// MARK: - Serialization

extension BulkSections: JSONDeserializable {

    init?(json: JSONDictionary) {

        let offset = json[JSONKeys.offset.rawValue] as! Int
        let limit = json[JSONKeys.limit.rawValue] as! Int
        let size = json[JSONKeys.size.rawValue] as! Int
        let linksDict = json[JSONKeys._links.rawValue] as! JSONDictionary
        let _links = Links(next: linksDict[JSONKeys.next.rawValue] as? String, prev: linksDict[JSONKeys.prev.rawValue] as? String)
        let sectionsDict = json[JSONKeys.sections.rawValue] as! [JSONDictionary]
        var sections = [Section]()
        for sectionDict in sectionsDict {
            if let section = Section.init(json: sectionDict) {
                sections.append(section)
            }
        }
        
        self.init(offset: offset, limit: limit, size: size, sections: sections, _links: _links)
    }

}

extension BulkSections: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.offset.rawValue: offset,
                JSONKeys.limit.rawValue: limit,
                JSONKeys.size.rawValue: size,
                JSONKeys._links.rawValue: _links,
                JSONKeys.sections.rawValue: sections]
    }
}
