import XCTest
@testable import QuizTrain

// MARK: - Tests

class JSONDictionaryContainerTests: XCTestCase {

    typealias Object = JSONDictionaryContainer

    func testInit() {

        XCTAssertEqual(Object(json: json).json.count, json.count)

        for (k, v) in json {
            XCTAssertEqual(Object(json: [k: v]).json.count, 1)
        }
    }

    func testInitWithEmptyJSON() {
        XCTAssertEqual(Object(json: [:]).json.count, 0)
    }

    func testJSONDeserializing() {
        assertJSONDeserializing(type: Object.self, from: json)
        assertJSONDeserializing(type: Object.self, from: [json, json, json])
    }

    func testJSONSerializing() {

        let objectA = Object(json: json)

        assertJSONSerializing(objectA)
        assertJSONSerializing([objectA, objectA, objectA])

        var objectB = Object(json: json)
        objectB.json["A new JSON Key"] = "Howdy!"

        assertJSONSerializing(objectB)
        assertJSONSerializing([objectB, objectB, objectB])
    }

    func testJSONTwoWaySerialization() {

        assertJSONTwoWaySerialization(json)
        assertJSONTwoWaySerialization([json, json, json])

        let objectA = Object(json: json)

        assertJSONTwoWaySerialization(objectA)
        assertJSONTwoWaySerialization([objectA, objectA, objectA])

        var objectB = Object(json: json)
        objectB.json["A new JSON Key"] = "Howdy!"

        assertJSONTwoWaySerialization(objectB)
        assertJSONTwoWaySerialization([objectB, objectB, objectB])
    }

    func testEquatable() {

        let objectA = Object(json: json)
        var objectB = Object(json: json)
        let objectC = Object(json: ["Key": "Value!"])

        XCTAssertEqual(objectA, objectA)
        XCTAssertEqual(objectA, objectB)
        XCTAssertNotEqual(objectA, objectC)

        objectB.json["A new JSON Key"] = "Howdy!"
        XCTAssertNotEqual(objectA, objectB)
        objectB.json.removeValue(forKey: "A new JSON Key")
        XCTAssertEqual(objectA, objectB)

        let key = json.keys.first!
        objectB.json[key] = "New Value"
        XCTAssertNotEqual(objectA, objectB)
        objectB.json[key] = json[key]
        XCTAssertEqual(objectA, objectB)
    }

    func testAddingJSON() {

        var object = Object(json: json)
        let key: JSONKey = "A new JSON Key"
        object.json[key] = 6000

        XCTAssertEqual(object.json.count, json.count + 1)
        XCTAssertNotNil(object.json[key])
        XCTAssertEqual(object.json[key] as! Int, 6000)
    }

    func testRemovingJSON() {

        var object = Object(json: json)
        let key: JSONKey = json.keys.first!

        object.json.removeValue(forKey: key)

        XCTAssertNil(object.json[key])
        XCTAssertEqual(object.json.count, json.count - 1)
    }

    func testAddingAndRemovingJSON() {

        var object = Object(json: json)
        let key = json.keys.first!
        let value = object.json[key]!

        object.json.removeValue(forKey: key)

        XCTAssertNil(object.json[key])
        XCTAssertNotEqual(object.json.count, json.count)

        object.json[key] = value

        XCTAssertNotNil(object.json[key])
        XCTAssertEqual(object.json.count, json.count)
    }

}

// MARK: - Data

extension JSONDictionaryContainerTests {

    var json: JSONDictionary {
        return ["Hello": "World!",
                "Pie": 3.14,
                "Array": [1, 2.0, "3", "4️⃣"],
                "Dictionary": ["Three": "🐹🐹🐹", "Party like it's": 1999]]
    }

}

// MARK: - Assertions

extension JSONDictionaryContainerTests: AssertJSONDeserializing { }

extension JSONDictionaryContainerTests: AssertJSONSerializing { }

extension JSONDictionaryContainerTests: AssertJSONTwoWaySerialization { }
