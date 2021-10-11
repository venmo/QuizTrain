import XCTest
@testable import QuizTrain

// MARK: - Tests

class ConfigurationGroupTests: XCTestCase, ModelTests {

    typealias Object = ConfigurationGroup

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

extension ConfigurationGroupTests {

    struct Properties {

        struct Required {
            static let configs = [ConfigurationTests.objectWithRequiredAndOptionalPropertiesFromJSON!, ConfigurationTests.objectWithRequiredPropertiesFromJSON!, ConfigurationTests.objectWithRequiredAndOptionalPropertiesFromJSON!] // This must match the order and datasources in: JSON.required["configs"]
            static let id = 10
            static let name = "Name"
            static let projectId = 11
        }

        struct Optional {
            // none
        }

    }

}

extension ConfigurationGroupTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.configs.rawValue: [ConfigurationTests.requiredAndOptionalJSON, ConfigurationTests.requiredJSON, ConfigurationTests.requiredAndOptionalJSON], // This must match the order and datasources in: Properties.Required.configs
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.name.rawValue: Properties.Required.name,
                Object.JSONKeys.projectId.rawValue: Properties.Required.projectId]
    }

    static var optionalJSON: JSONDictionary {
        return [:] // none
    }

}

// MARK: - Objects

extension ConfigurationGroupTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(configs: Properties.Required.configs,
                      id: Properties.Required.id,
                      name: Properties.Required.name,
                      projectId: Properties.Required.projectId)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(configs: Properties.Required.configs,
                      id: Properties.Required.id,
                      name: Properties.Required.name,
                      projectId: Properties.Required.projectId)
    }

}

// MARK: - Assertions

extension ConfigurationGroupTests: AssertEquatable { }

extension ConfigurationGroupTests: AssertJSONDeserializing { }

extension ConfigurationGroupTests: AssertJSONSerializing { }

extension ConfigurationGroupTests: AssertJSONTwoWaySerialization { }

extension ConfigurationGroupTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.configs.count, Properties.Required.configs.count)
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.projectId, Properties.Required.projectId)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {
        object.name = "New Name"
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.name, "New Name")
    }

}

extension ConfigurationGroupTests: AssertUpdateRequestJSON { }
