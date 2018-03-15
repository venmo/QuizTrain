import XCTest
@testable import QuizTrain

// MARK: - Tests

class Plan_EntryTests: XCTestCase, ModelTests {

    typealias Object = Plan.Entry

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

extension Plan_EntryTests {

    struct Properties {

        struct Required {
            static let id = "Id"
            static let name = "Name"
            static let runs = [RunTests.objectWithRequiredAndOptionalPropertiesFromJSON!, RunTests.objectWithRequiredPropertiesFromJSON!, RunTests.objectWithRequiredAndOptionalPropertiesFromJSON!] // This must match the order and datasources in: JSON.required["runs"]
            static let suiteId = 10
        }

        struct Optional {
            // none
        }

    }

}

extension Plan_EntryTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.name.rawValue: Properties.Required.name,
                Object.JSONKeys.runs.rawValue: [RunTests.requiredAndOptionalJSON, RunTests.requiredJSON, RunTests.requiredAndOptionalJSON], // This must match the order and datasources in: Properties.Required.runs
                Object.JSONKeys.suiteId.rawValue: Properties.Required.suiteId]
    }

    static var optionalJSON: JSONDictionary {
        return [:] // none
    }

}

// MARK: - Objects

extension Plan_EntryTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(id: Properties.Required.id,
                      name: Properties.Required.name,
                      runs: Properties.Required.runs,
                      suiteId: Properties.Required.suiteId)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(id: Properties.Required.id,
                      name: Properties.Required.name,
                      runs: Properties.Required.runs,
                      suiteId: Properties.Required.suiteId)
    }

}

// MARK: - Assertions

extension Plan_EntryTests: AssertEquatable { }

extension Plan_EntryTests: AssertJSONDeserializing { }

extension Plan_EntryTests: AssertJSONSerializing { }

extension Plan_EntryTests: AssertJSONTwoWaySerialization { }

extension Plan_EntryTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.runs.count, Properties.Required.runs.count)
        XCTAssertEqual(object.suiteId, Properties.Required.suiteId)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {
        object.name = "New Name"
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.name, "New Name")
    }

}

extension Plan_EntryTests: AssertUpdateRequestJSON { }
