import XCTest
@testable import QuizTrain

// MARK: - Tests

class CaseTypeTests: XCTestCase, ModelTests {

    typealias Object = CaseType

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

extension CaseTypeTests {

    struct Properties {

        struct Required {
            static let id = 10
            static let isDefault = true
            static let name = "Name"
        }

        struct Optional {
            // none
        }

    }

}

extension CaseTypeTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.isDefault.rawValue: Properties.Required.isDefault,
                Object.JSONKeys.name.rawValue: Properties.Required.name]
    }

    static var optionalJSON: JSONDictionary {
        return [:] // none
    }

}

// MARK: - Objects

extension CaseTypeTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(id: Properties.Required.id,
                      isDefault: Properties.Required.isDefault,
                      name: Properties.Required.name)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(id: Properties.Required.id,
                      isDefault: Properties.Required.isDefault,
                      name: Properties.Required.name)
    }

}

// MARK: - Assertions

extension CaseTypeTests: AssertEquatable { }

extension CaseTypeTests: AssertJSONDeserializing { }

extension CaseTypeTests: AssertJSONSerializing { }

extension CaseTypeTests: AssertJSONTwoWaySerialization { }

extension CaseTypeTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.isDefault, Properties.Required.isDefault)
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
