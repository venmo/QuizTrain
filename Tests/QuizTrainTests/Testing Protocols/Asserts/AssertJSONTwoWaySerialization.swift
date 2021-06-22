import XCTest
@testable import QuizTrain

protocol AssertJSONTwoWaySerialization {
    associatedtype Object: Equatable, JSONDeserializable, JSONSerializable
    func assertJSONTwoWaySerialization(_ json: JSONDictionary)
    func assertJSONTwoWaySerialization(_ json: [JSONDictionary])
    func assertJSONTwoWaySerialization(_ object: Object)
    func assertJSONTwoWaySerialization(_ objects: [Object])
}

extension AssertJSONTwoWaySerialization {

    // MARK: JSON to Object(s) to JSON

    func assertJSONTwoWaySerialization(_ json: JSONDictionary) {

        let object: Object? = Object.deserialized(json)
        XCTAssertNotNil(object)

        // Instance Method
        let serializedA: JSONDictionary = object!.serialized()

        for (k, _) in json {
            XCTAssertNotNil(serializedA[k])
        }

        let deserializedA: Object? = Object.deserialized(serializedA)
        XCTAssertNotNil(deserializedA)
        XCTAssertEqual(deserializedA!, object!)

        // Class Method
        let serializedB: JSONDictionary = Object.serialized(object!)

        for (k, _) in json {
            XCTAssertNotNil(serializedB[k])
        }

        let deserializedB: Object? = Object.deserialized(serializedB)
        XCTAssertNotNil(deserializedB)
        XCTAssertEqual(deserializedB!, object!)
    }

    func assertJSONTwoWaySerialization(_ json: [JSONDictionary]) {

        let objects: [Object]? = Object.deserialized(json)
        XCTAssertNotNil(objects)
        XCTAssertEqual(objects!.count, json.count)

        let serialized: [JSONDictionary] = Object.serialized(objects!)
        XCTAssertEqual(serialized.count, json.count)

        let deserialized: [Object]? = Object.deserialized(serialized)
        XCTAssertNotNil(deserialized)
        XCTAssertEqual(deserialized!, objects!)
    }

    // MARK: Object(s) to JSON to Object(s)

    func assertJSONTwoWaySerialization(_ object: Object) {

        // Instance Method
        let serializedA: JSONDictionary = object.serialized()
        let deserializedA: Object? = Object.deserialized(serializedA)

        XCTAssertNotNil(deserializedA)
        XCTAssertEqual(deserializedA!, object)

        // Class Method
        let serializedB: JSONDictionary = Object.serialized(object)
        let deserializedB: Object? = Object.deserialized(serializedB)

        XCTAssertNotNil(deserializedB)
        XCTAssertEqual(deserializedB!, object)
    }

    func assertJSONTwoWaySerialization(_ objects: [Object]) {

        let serialized: [JSONDictionary] = Object.serialized(objects)
        XCTAssertEqual(serialized.count, objects.count)

        let deserialized: [Object]? = Object.deserialized(serialized)
        XCTAssertNotNil(deserialized)
        XCTAssertEqual(deserialized!, objects)
    }

}
