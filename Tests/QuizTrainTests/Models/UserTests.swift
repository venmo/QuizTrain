import XCTest
@testable import QuizTrain

// MARK: - Tests

class UserTests: XCTestCase, ModelTests {

    typealias Object = User

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

extension UserTests {

    struct Properties {

        struct Required {
            static let email = "hello@email.com"
            static let id = 108
            static let isActive = true
            static let name = "Name"
        }

        struct Optional { /* none */ }

    }

}

extension UserTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.email.rawValue: Properties.Required.email,
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.isActive.rawValue: Properties.Required.isActive,
                Object.JSONKeys.name.rawValue: Properties.Required.name]
    }

    static var optionalJSON: JSONDictionary {
        return [:] // none
    }

}

// MARK: - Objects

extension UserTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(email: Properties.Required.email,
                      id: Properties.Required.id,
                      isActive: Properties.Required.isActive,
                      name: Properties.Required.name)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(email: Properties.Required.email,
                      id: Properties.Required.id,
                      isActive: Properties.Required.isActive,
                      name: Properties.Required.name)
    }

}

// MARK: - Assertions

extension UserTests: AssertEquatable { }

extension UserTests: AssertJSONDeserializing { }

extension UserTests: AssertJSONSerializing { }

extension UserTests: AssertJSONTwoWaySerialization { }

extension UserTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.email, Properties.Required.email)
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.isActive, Properties.Required.isActive)
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
