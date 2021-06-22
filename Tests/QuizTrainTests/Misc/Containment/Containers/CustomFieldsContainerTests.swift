import XCTest
@testable import QuizTrain

// MARK: - Tests

class CustomFieldsContainerTests: XCTestCase {

    typealias Object = CustomFieldsContainer

    func testInit() {

        XCTAssertEqual(Object(json: customFields).customFields.count, customFields.count)

        for (k, v) in customFields {
            XCTAssertEqual(Object(json: [k: v]).customFields.count, 1)
        }
    }

    func testInitWithEmptyCustomFields() {
        XCTAssertEqual(Object(json: emptyCustomFields).customFields.count, 0)
    }

    func testInitWithInvalidCustomFields() {

        XCTAssertEqual(Object(json: invalidCustomFields).customFields.count, 0)

        for (k, v) in invalidCustomFields {
            XCTAssertEqual(Object(json: [k: v]).customFields.count, 0)
        }
    }

    func testInitWithValidAndInvalidCustomFields() {

        let object = Object(json: validAndInvalidCustomFields)
        XCTAssertEqual(object.customFields.count, customFields.count)

        for (k, _) in object.customFields {
            XCTAssertTrue(customFieldsKeys.contains(k))
            XCTAssertFalse(invalidCustomFieldsKeys.contains(k))
        }
    }

    func testInitOmittingCustomKeys() {

        XCTAssertEqual(Object(json: customFields, omittingKeys: []).customFields.count, customFields.count)
        XCTAssertEqual(Object(json: customFields, omittingKeys: customFieldsKeys).customFields.count, 0)

        for key in customFieldsKeys {
            let object = Object(json: customFields, omittingKeys: [key])
            XCTAssertEqual(object.customFields.count, customFields.count - 1)
            XCTAssertNil(object.customFields[key])
        }
    }

    func testInitOmittingCustomKeysWithEmptyCustomFields() {
        XCTAssertEqual(Object(json: emptyCustomFields, omittingKeys: []).customFields.count, 0)
        XCTAssertEqual(Object(json: emptyCustomFields, omittingKeys: customFieldsKeys).customFields.count, 0)
    }

    func testInitOmittingCustomKeysWithInvalidCustomFields() {
        XCTAssertEqual(Object(json: invalidCustomFields, omittingKeys: []).customFields.count, 0)
        XCTAssertEqual(Object(json: invalidCustomFields, omittingKeys: customFieldsKeys).customFields.count, 0)
        XCTAssertEqual(Object(json: invalidCustomFields, omittingKeys: invalidCustomFieldsKeys).customFields.count, 0)
    }

    func testInitOmittingCustomKeysWithValidAndInvalidCustomFields() {
        XCTAssertEqual(Object(json: validAndInvalidCustomFields, omittingKeys: []).customFields.count, customFields.count)
        XCTAssertEqual(Object(json: validAndInvalidCustomFields, omittingKeys: invalidCustomFieldsKeys).customFields.count, customFields.count)
        XCTAssertEqual(Object(json: validAndInvalidCustomFields, omittingKeys: customFieldsKeys).customFields.count, 0)
    }

    func testJSONDeserializing() {
        assertJSONDeserializing(type: Object.self, from: customFields)
        assertJSONDeserializing(type: Object.self, from: [customFields, customFields, customFields])
    }

    func testJSONSerializing() {

        let objectA = Object(json: customFields)

        assertJSONSerializing(objectA)
        assertJSONSerializing([objectA, objectA, objectA])

        var objectB = Object(json: customFields)
        objectB.customFields["custom_addingANewCustomField"] = "Howdy!"

        assertJSONSerializing(objectB)
        assertJSONSerializing([objectB, objectB, objectB])
    }

    func testJSONTwoWaySerialization() {

        assertJSONTwoWaySerialization(customFields)
        assertJSONTwoWaySerialization([customFields, customFields, customFields])

        let objectA = Object(json: customFields)

        assertJSONTwoWaySerialization(objectA)
        assertJSONTwoWaySerialization([objectA, objectA, objectA])

        var objectB = Object(json: customFields)
        objectB.customFields["custom_addingANewCustomField"] = "Howdy!"

        assertJSONTwoWaySerialization(objectB)
        assertJSONTwoWaySerialization([objectB, objectB, objectB])
    }

    func testEquatable() {

        let objectA = Object(json: customFields)
        var objectB = Object(json: customFields)
        let objectC = Object(json: ["custom_field": "Hi"])

        XCTAssertEqual(objectA, objectA)
        XCTAssertEqual(objectA, objectB)
        XCTAssertNotEqual(objectA, objectC)

        objectB.customFields["custom_addingANewCustomField"] = "Howdy!"
        XCTAssertNotEqual(objectA, objectB)
        objectB.customFields.removeValue(forKey: "custom_addingANewCustomField")
        XCTAssertEqual(objectA, objectB)

        let key = customFieldsKeys.sorted().first!
        objectB.customFields[key] = "New Value"
        XCTAssertNotEqual(objectA, objectB)
        objectB.customFields[key] = customFields[key]
        XCTAssertEqual(objectA, objectB)
    }

    func testAddingCustomFields() {

        // Valid

        var objectA = Object(json: customFields)
        objectA.customFields["custom_validKey"] = 6000

        XCTAssertEqual(objectA.customFields.count, customFields.count + 1)
        XCTAssertNotNil(objectA.customFields["custom_validKey"])
        XCTAssertEqual(objectA.customFields["custom_validKey"] as! Int, 6000)

        // Invalid

        var objectB = Object(json: customFields)
        objectB.customFields["This is not a valid custom_ key"] = "At least it better be!"

        XCTAssertEqual(objectB.customFields.count, customFields.count)
        XCTAssertNil(objectA.customFields["This is not a valid custom_ key"])

        // Overwrite

        var objectC = Object(json: customFields)
        let key = customFieldsKeys.sorted().first!
        objectC.customFields[key] = "New Value"

        XCTAssertEqual(objectC.customFields.count, customFields.count)
        XCTAssertEqual(objectC.customFields[key] as! String, "New Value")

        objectC.customFields[key] = customFields[key]
        XCTAssertEqual(objectC.customFields[key] as! Int, customFields[key] as! Int)
    }

    func testAddingCustomFieldsWithOmittedKeys() {

        let omittedKeys: [JSONKey] = ["custom_hamsters", "custom_grubb"]
        var object = Object(json: customFields, omittingKeys: omittedKeys)

        XCTAssertEqual(object.omittedKeys, omittedKeys)
        XCTAssertEqual(object.customFields.count, customFields.count)

        object.customFields["custom_hamsters"] = "🐹🐹🐹"
        XCTAssertNil(object.customFields["custom_hamsters"])
        XCTAssertEqual(object.customFields.count, customFields.count)

        object.customFields["custom_grubb"] = "🐛"
        XCTAssertNil(object.customFields["custom_grubb"])
        XCTAssertEqual(object.customFields.count, customFields.count)

        object.customFields["custom_dolphin"] = "🐬"
        XCTAssertNotNil(object.customFields["custom_dolphin"])
        XCTAssertEqual(object.customFields.count, customFields.count + 1)
    }

    func testRemovingCustomFields() {

        var object = Object(json: customFields)
        let key = customFieldsKeys.sorted().first!

        object.customFields.removeValue(forKey: key)

        XCTAssertNil(object.customFields[key])
        XCTAssertEqual(object.customFields.count, customFields.count - 1)
    }

    func testRemovingAndAddingCustomFields() {

        var object = Object(json: customFields)
        let key = customFieldsKeys.sorted().first!
        let value = object.customFields[key]!

        object.customFields.removeValue(forKey: key)

        XCTAssertNil(object.customFields[key])
        XCTAssertNotEqual(object.customFields.count, customFields.count)

        object.customFields[key] = value

        XCTAssertNotNil(object.customFields[key])
        XCTAssertEqual(object.customFields.count, customFields.count)
    }

    func testEmpty() {
        let object = Object.empty()
        XCTAssertEqual(object.customFields.count, 0)
    }

}

// MARK: - Data

extension CustomFieldsContainerTests: CustomFieldsDataProvider { }

// MARK: - Assertions

extension CustomFieldsContainerTests: AssertJSONDeserializing { }

extension CustomFieldsContainerTests: AssertJSONSerializing { }

extension CustomFieldsContainerTests: AssertJSONTwoWaySerialization { }
