import XCTest
@testable import QuizTrain

// MARK: - Tests

class Config_ContextTests: XCTestCase, ModelTests {

    typealias Object = Config.Context

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

extension Config_ContextTests {

    struct Properties {

        struct Required {
            static let isGlobal = true
        }

        struct Optional {
            static let projectIds = [1, 2, 3, 4, 5]
        }

    }

}

extension Config_ContextTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.isGlobal.rawValue: Properties.Required.isGlobal]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.projectIds.rawValue: Properties.Optional.projectIds]
    }

}

// MARK: - Objects

extension Config_ContextTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(isGlobal: Properties.Required.isGlobal,
                      projectIds: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(isGlobal: Properties.Required.isGlobal,
                      projectIds: Properties.Optional.projectIds)
    }

}

// MARK: - Assertions

extension Config_ContextTests: AssertEquatable { }

extension Config_ContextTests: AssertJSONDeserializing { }

extension Config_ContextTests: AssertJSONSerializing { }

extension Config_ContextTests: AssertJSONTwoWaySerialization { }

extension Config_ContextTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.isGlobal, Properties.Required.isGlobal)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.projectIds)
        } else {
            XCTAssertNotNil(object.projectIds)
            XCTAssertEqual(object.projectIds!, Properties.Optional.projectIds)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
