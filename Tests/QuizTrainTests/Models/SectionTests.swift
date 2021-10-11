import XCTest
@testable import QuizTrain

// MARK: - Tests

class SectionTests: XCTestCase, ModelTests {

    typealias Object = Section

    func testEquatable() {
        _testEquatable()
    }

    func testInit() {
        _testInit()
    }

    func testInitWithOptionalProperties() {
        _testInitWithOptionalProperties()
    }

    func testJSONDeserializing() {
        _testJSONDeserializing()
    }

    func testJSONDeserializingWithOptionalProperties() {
        _testJSONDeserializingWithOptionalProperties()
    }

    func testJSONDeserializingASingleObject() {
        _testJSONDeserializingASingleObject()
    }

    func testJSONDeserializingMultipleObjects() {
        _testJSONDeserializingMultipleObjects()
    }

    func testJSONDeserializingASingleObjectMissingRequiredProperties() {
        _testJSONDeserializingASingleObjectMissingRequiredProperties()
    }

    func testJSONDeserializingMultipleObjectsMissingRequiredProperties() {
        _testJSONDeserializingMultipleObjectsMissingRequiredProperties()
    }

    func testJSONSerializingSingleObjects() {
        _testJSONSerializingSingleObjects()
    }

    func testJSONSerializingMultipleObjects() {
        _testJSONSerializingMultipleObjects()
    }

    func testJSONTwoWaySerializationForSingleItems() {
        _testJSONTwoWaySerializationForSingleItems()
    }

    func testJSONTwoWaySerializationForMultipleItems() {
        _testJSONTwoWaySerializationForMultipleItems()
    }

    func testVariableProperties() {
        _testVariableProperties()
    }

    func testUpdateRequestJSON() {
        _testUpdateRequestJSON()
    }

}

// MARK: - Data

extension SectionTests {

    struct Properties {

        struct Required {
            static let depth = 2
            static let displayOrder = 1
            static let id = 2733
            static let name = "Name"
        }

        struct Optional {
            static let description = "Description"
            static let parentId = 382
            static let suiteId = 33
        }

    }

}

extension SectionTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.depth.rawValue: Properties.Required.depth,
                Object.JSONKeys.displayOrder.rawValue: Properties.Required.displayOrder,
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.name.rawValue: Properties.Required.name]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.description.rawValue: Properties.Optional.description,
                Object.JSONKeys.parentId.rawValue: Properties.Optional.parentId,
                Object.JSONKeys.suiteId.rawValue: Properties.Optional.suiteId]
    }

}

// MARK: - Objects

extension SectionTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(depth: Properties.Required.depth,
                      description: nil,
                      displayOrder: Properties.Required.displayOrder,
                      id: Properties.Required.id,
                      name: Properties.Required.name,
                      parentId: nil,
                      suiteId: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(depth: Properties.Required.depth,
                      description: Properties.Optional.description,
                      displayOrder: Properties.Required.displayOrder,
                      id: Properties.Required.id,
                      name: Properties.Required.name,
                      parentId: Properties.Optional.parentId,
                      suiteId: Properties.Optional.suiteId)
    }

}

// MARK: - Assertions

extension SectionTests: AssertEquatable { }

extension SectionTests: AssertJSONDeserializing { }

extension SectionTests: AssertJSONSerializing { }

extension SectionTests: AssertJSONTwoWaySerialization { }

extension SectionTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.depth, Properties.Required.depth)
        XCTAssertEqual(object.displayOrder, Properties.Required.displayOrder)
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.description)
            XCTAssertNil(object.parentId)
            XCTAssertNil(object.suiteId)
        } else {
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.parentId)
            XCTAssertNotNil(object.suiteId)
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.parentId, Properties.Optional.parentId)
            XCTAssertEqual(object.suiteId, Properties.Optional.suiteId)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.description = "New Description"
        object.name = "New Name"

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.name, Properties.Required.name)

        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.name, "New Name")
    }

}

extension SectionTests: AssertUpdateRequestJSON { }
