public struct BulkTests {
    public let offset: Int
    public let limit: Int
    public let size: Int
    public let tests: [Test]
    public let _links: Links
}

// MARK: - JSON Keys

extension BulkTests {

    enum JSONKeys: JSONKey {
        case offset = "offset"
        case limit = "limit"
        case size = "size"
        case _links = "_links"
        case tests = "tests"
        case next = "next"
        case prev = "prev"
    }

}

// MARK: - Serialization

extension BulkTests: JSONDeserializable {

    init?(json: JSONDictionary) {

        let offset = json[JSONKeys.offset.rawValue] as! Int
        let limit = json[JSONKeys.limit.rawValue] as! Int
        let size = json[JSONKeys.size.rawValue] as! Int
        let linksDict = json[JSONKeys._links.rawValue] as! JSONDictionary
        let _links = Links(next: linksDict[JSONKeys.next.rawValue] as? String, prev: linksDict[JSONKeys.prev.rawValue] as? String)
        let testsDict = json[JSONKeys.tests.rawValue] as! [JSONDictionary]
        let tests = testsDict.map({ Test.init(json: $0)! })
    
        self.init(offset: offset, limit: limit, size: size, tests: tests, _links: _links)
    }

}

extension BulkTests: JSONSerializable {

    func serialized() -> JSONDictionary {
        return [JSONKeys.offset.rawValue: offset,
                JSONKeys.limit.rawValue: limit,
                JSONKeys.size.rawValue: size,
                JSONKeys._links.rawValue: _links,
                JSONKeys.tests.rawValue: tests]
    }
}
