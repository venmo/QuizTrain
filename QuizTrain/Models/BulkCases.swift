public struct BulkCases {
    public let offset: Int
    public let limit: Int
    public let size: Int
    public let cases: [Case]
    public let _links: Links
}

// MARK: - JSON Keys

extension BulkCases {

    enum JSONKeys: JSONKey {
        case offset = "offset"
        case limit = "limit"
        case size = "size"
        case _links = "_links"
        case cases = "cases"
        case next = "next"
        case prev = "prev"
    }

}

// MARK: - Serialization

extension BulkCases: JSONDeserializable {

    init?(json: JSONDictionary) {

        let offset = json[JSONKeys.offset.rawValue] as! Int
        let limit = json[JSONKeys.limit.rawValue] as! Int
        let size = json[JSONKeys.size.rawValue] as! Int
        let linksDict = json[JSONKeys._links.rawValue] as! JSONDictionary
        let _links = Links(next: linksDict[JSONKeys.next.rawValue] as? String, prev: linksDict[JSONKeys.prev.rawValue] as? String)
        let casesDict = json[JSONKeys.cases.rawValue] as! [JSONDictionary]
        var cases = [Case]()
        for caseDict in casesDict {
            let caseResult = Case.init(json: caseDict)
            cases.append(caseResult!)
        }
        
        self.init(offset: offset, limit: limit, size: size, cases: cases, _links: _links)
    }
}

extension BulkCases: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.offset.rawValue: offset,
                JSONKeys.limit.rawValue: limit,
                JSONKeys.size.rawValue: size,
                JSONKeys._links.rawValue: _links,
                JSONKeys.cases.rawValue: cases]
    }
}
