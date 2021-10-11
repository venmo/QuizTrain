import XCTest
@testable import QuizTrain

// MARK: - Tests

class StatusTests: XCTestCase, ModelTests {

    typealias Object = Status

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

extension StatusTests {

    struct Properties {

        struct Required {
            static let colorBright = 1000
            static let colorDark = 1001
            static let colorMedium = 1002
            static let id = 1
            static let isFinal = true
            static let isSystem = true
            static let isUntested = true
            static let label = "Label"
            static let name = "Name"
        }

        struct Optional { /* none */ }

    }

}

extension StatusTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.colorBright.rawValue: Properties.Required.colorBright,
                Object.JSONKeys.colorDark.rawValue: Properties.Required.colorDark,
                Object.JSONKeys.colorMedium.rawValue: Properties.Required.colorMedium,
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.isFinal.rawValue: Properties.Required.isFinal,
                Object.JSONKeys.isSystem.rawValue: Properties.Required.isSystem,
                Object.JSONKeys.isUntested.rawValue: Properties.Required.isUntested,
                Object.JSONKeys.label.rawValue: Properties.Required.label,
                Object.JSONKeys.name.rawValue: Properties.Required.name]
    }

    static var optionalJSON: JSONDictionary {
        return [:] // none
    }

}

// MARK: - Objects

extension StatusTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(colorBright: Properties.Required.colorBright,
                      colorDark: Properties.Required.colorDark,
                      colorMedium: Properties.Required.colorMedium,
                      id: Properties.Required.id,
                      isFinal: Properties.Required.isFinal,
                      isSystem: Properties.Required.isSystem,
                      isUntested: Properties.Required.isUntested,
                      label: Properties.Required.label,
                      name: Properties.Required.name)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(colorBright: Properties.Required.colorBright,
                      colorDark: Properties.Required.colorDark,
                      colorMedium: Properties.Required.colorMedium,
                      id: Properties.Required.id,
                      isFinal: Properties.Required.isFinal,
                      isSystem: Properties.Required.isSystem,
                      isUntested: Properties.Required.isUntested,
                      label: Properties.Required.label,
                      name: Properties.Required.name)
    }

}

// MARK: - Assertions

extension StatusTests: AssertEquatable { }

extension StatusTests: AssertJSONDeserializing { }

extension StatusTests: AssertJSONSerializing { }

extension StatusTests: AssertJSONTwoWaySerialization { }

extension StatusTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.colorBright, Properties.Required.colorBright)
        XCTAssertEqual(object.colorDark, Properties.Required.colorDark)
        XCTAssertEqual(object.colorMedium, Properties.Required.colorMedium)
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.isFinal, Properties.Required.isFinal)
        XCTAssertEqual(object.isSystem, Properties.Required.isSystem)
        XCTAssertEqual(object.isUntested, Properties.Required.isUntested)
        XCTAssertEqual(object.label, Properties.Required.label)
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
