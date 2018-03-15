import XCTest
@testable import QuizTrain

// MARK: - Tests

class SuiteTests: XCTestCase, ModelTests {

    typealias Object = Suite

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

extension SuiteTests {

    struct Properties {

        struct Required {
            static let id = 27
            static let isBaseline = true
            static let isCompleted = true
            static let isMaster = true
            static let name = "Name"
            static let projectId = 3
            static let url = URL(string: "https://www.testrail.com/")!
        }

        struct Optional {
            static let completedOn = Date(secondsSince1970: 72973833)
            static let description = "Description"
        }

    }

}

extension SuiteTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.isBaseline.rawValue: Properties.Required.isBaseline,
                Object.JSONKeys.isCompleted.rawValue: Properties.Required.isCompleted,
                Object.JSONKeys.isMaster.rawValue: Properties.Required.isMaster,
                Object.JSONKeys.name.rawValue: Properties.Required.name,
                Object.JSONKeys.projectId.rawValue: Properties.Required.projectId,
                Object.JSONKeys.url.rawValue: Properties.Required.url.absoluteString]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.completedOn.rawValue: Properties.Optional.completedOn.secondsSince1970,
                Object.JSONKeys.description.rawValue: Properties.Optional.description]
    }

}

// MARK: - Objects

extension SuiteTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(completedOn: nil,
                      description: nil,
                      id: Properties.Required.id,
                      isBaseline: Properties.Required.isBaseline,
                      isCompleted: Properties.Required.isCompleted,
                      isMaster: Properties.Required.isMaster,
                      name: Properties.Required.name,
                      projectId: Properties.Required.projectId,
                      url: Properties.Required.url)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(completedOn: Properties.Optional.completedOn,
                      description: Properties.Optional.description,
                      id: Properties.Required.id,
                      isBaseline: Properties.Required.isBaseline,
                      isCompleted: Properties.Required.isCompleted,
                      isMaster: Properties.Required.isMaster,
                      name: Properties.Required.name,
                      projectId: Properties.Required.projectId,
                      url: Properties.Required.url)
    }

}

// MARK: - Assertions

extension SuiteTests: AssertEquatable { }

extension SuiteTests: AssertJSONDeserializing { }

extension SuiteTests: AssertJSONSerializing { }

extension SuiteTests: AssertJSONTwoWaySerialization { }

extension SuiteTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.isBaseline, Properties.Required.isBaseline)
        XCTAssertEqual(object.isCompleted, Properties.Required.isCompleted)
        XCTAssertEqual(object.isMaster, Properties.Required.isMaster)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.projectId, Properties.Required.projectId)
        XCTAssertEqual(object.url, Properties.Required.url)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.completedOn)
            XCTAssertNil(object.description)
        } else {
            XCTAssertNotNil(object.completedOn)
            XCTAssertNotNil(object.description)
            XCTAssertEqual(object.completedOn, Properties.Optional.completedOn)
            XCTAssertEqual(object.description, Properties.Optional.description)
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

extension SuiteTests: AssertUpdateRequestJSON { }
