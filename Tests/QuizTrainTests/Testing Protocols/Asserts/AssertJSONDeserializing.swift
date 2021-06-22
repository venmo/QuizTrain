import XCTest
@testable import QuizTrain

protocol AssertJSONDeserializing {
    func assertJSONDeserializing<Object: JSONDeserializable>(type: Object.Type, from json: JSONDictionary)
    func assertJSONDeserializing<Object: JSONDeserializable>(type: Object.Type, from json: [JSONDictionary])
    func assertJSONDeserializing<Object: JSONDeserializable>(type: Object.Type, failsByOmittingKeysFrom json: JSONDictionary)
    func assertJSONDeserializing<Object: JSONDeserializable>(type: Object.Type, failsByOmittingKeysFrom json: [JSONDictionary])
}

extension AssertJSONDeserializing {

    func assertJSONDeserializing<Object: JSONDeserializable>(type: Object.Type, from json: JSONDictionary) {
        let object: Object? = Object.deserialized(json)
        XCTAssertNotNil(object)
    }

    func assertJSONDeserializing<Object: JSONDeserializable>(type: Object.Type, from json: [JSONDictionary]) {
        let objects: [Object]? = Object.deserialized(json)
        XCTAssertNotNil(objects)
        XCTAssertEqual(objects!.count, json.count)
    }

    func assertJSONDeserializing<Object: JSONDeserializable>(type: Object.Type, failsByOmittingKeysFrom json: JSONDictionary) {
        for (k, _) in json {
            var incompleteJson = json
            incompleteJson.removeValue(forKey: k)
            let object: Object? = Object.deserialized(incompleteJson)
            XCTAssertNil(object)
        }
    }

    func assertJSONDeserializing<Object: JSONDeserializable>(type: Object.Type, failsByOmittingKeysFrom json: [JSONDictionary]) {
        for index in 0..<json.count {
            let completeJson = json[index]
            var incompleteJsons = json
            for (k, _) in completeJson {
                var incompleteJson = completeJson
                incompleteJson.removeValue(forKey: k)
                incompleteJsons[index] = incompleteJson
                let objects: [Object]? = Object.deserialized(incompleteJsons)
                XCTAssertNil(objects)
            }
        }
    }

}
