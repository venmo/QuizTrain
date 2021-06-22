import XCTest
@testable import QuizTrain

// MARK: - Tests

class TemplateTests: XCTestCase, ModelTests {

    typealias Object = Template

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

extension TemplateTests {

    struct Properties {

        struct Required {
            static let isDefault = true
            static let id = 4
            static let name = "Name"
        }

        struct Optional {
            // none
        }

    }

}

extension TemplateTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.isDefault.rawValue: Properties.Required.isDefault,
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.name.rawValue: Properties.Required.name]
    }

    static var optionalJSON: JSONDictionary {
        return [:] // none
    }

}

// MARK: - Objects

extension TemplateTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(isDefault: Properties.Required.isDefault,
                      id: Properties.Required.id,
                      name: Properties.Required.name)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(isDefault: Properties.Required.isDefault,
                      id: Properties.Required.id,
                      name: Properties.Required.name)
    }

}

// MARK: - Assertions

extension TemplateTests: AssertEquatable { }

extension TemplateTests: AssertJSONDeserializing { }

extension TemplateTests: AssertJSONSerializing { }

extension TemplateTests: AssertJSONTwoWaySerialization { }

extension TemplateTests: AssertProperties {

    func assertRequiredProperties(in template: Object) {
        XCTAssertEqual(template.isDefault, Properties.Required.isDefault)
        XCTAssertEqual(template.id, Properties.Required.id)
        XCTAssertEqual(template.name, Properties.Required.name)
    }

    func assertOptionalProperties(in template: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
