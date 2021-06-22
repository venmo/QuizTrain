import XCTest
@testable import QuizTrain

// MARK: - Tests

class PriorityTests: XCTestCase, ModelTests {

    typealias Object = Priority

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

extension PriorityTests {

    struct Properties {

        struct Required {
            static let id = 472
            static let isDefault = true
            static let name = "Name"
            static let priority = 3
            static let shortName = "Short Name"
        }

        struct Optional {
            // none
        }

    }

}

extension PriorityTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.isDefault.rawValue: Properties.Required.isDefault,
                Object.JSONKeys.name.rawValue: Properties.Required.name,
                Object.JSONKeys.priority.rawValue: Properties.Required.priority,
                Object.JSONKeys.shortName.rawValue: Properties.Required.shortName]
    }

    static var optionalJSON: JSONDictionary {
        return [:] // none
    }

}

// MARK: - Objects

extension PriorityTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(id: Properties.Required.id,
                      isDefault: Properties.Required.isDefault,
                      name: Properties.Required.name,
                      priority: Properties.Required.priority,
                      shortName: Properties.Required.shortName)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(id: Properties.Required.id,
                      isDefault: Properties.Required.isDefault,
                      name: Properties.Required.name,
                      priority: Properties.Required.priority,
                      shortName: Properties.Required.shortName)
    }

}

// MARK: - Assertions

extension PriorityTests: AssertEquatable { }

extension PriorityTests: AssertJSONDeserializing { }

extension PriorityTests: AssertJSONSerializing { }

extension PriorityTests: AssertJSONTwoWaySerialization { }

extension PriorityTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.isDefault, Properties.Required.isDefault)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.priority, Properties.Required.priority)
        XCTAssertEqual(object.shortName, Properties.Required.shortName)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
