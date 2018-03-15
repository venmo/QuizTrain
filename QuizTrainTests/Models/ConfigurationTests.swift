import XCTest
@testable import QuizTrain

// MARK: - Tests

class ConfigurationTests: XCTestCase, ModelTests {

    typealias Object = Configuration

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

extension ConfigurationTests {

    struct Properties {

        struct Required {
            static let id = 10
            static let groupId = 11
            static let name = "Name"
        }

        struct Optional {
            // none
        }

    }

}

extension ConfigurationTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.groupId.rawValue: Properties.Required.groupId,
                Object.JSONKeys.name.rawValue: Properties.Required.name]
    }

    static var optionalJSON: JSONDictionary {
        return [:] // none
    }

}

// MARK: - Objects

extension ConfigurationTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(id: Properties.Required.id,
                      groupId: Properties.Required.groupId,
                      name: Properties.Required.name)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(id: Properties.Required.id,
                      groupId: Properties.Required.groupId,
                      name: Properties.Required.name)
    }

}

// MARK: - Assertions

extension ConfigurationTests: AssertEquatable { }

extension ConfigurationTests: AssertJSONDeserializing { }

extension ConfigurationTests: AssertJSONSerializing { }

extension ConfigurationTests: AssertJSONTwoWaySerialization { }

extension ConfigurationTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.groupId, Properties.Required.groupId)
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {
        object.name = "New Name"
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.name, "New Name")
    }

}

extension ConfigurationTests: AssertUpdateRequestJSON { }
