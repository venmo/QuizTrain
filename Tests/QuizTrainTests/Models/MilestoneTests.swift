import XCTest
@testable import QuizTrain

// MARK: - Tests

class MilestoneTests: XCTestCase, ModelTests {

    typealias Object = Milestone

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

extension MilestoneTests {

    struct Properties {

        struct Required {
            static let id = 10
            static let isCompleted = true
            static let isStarted = true
            static let name = "Name"
            static let projectId = 11
            static let url = URL(string: "https://www.testrail.com/")!
        }

        struct Optional {
            static let completedOn = Date(secondsSince1970: 72988302)
            static let description = "Description"
            static let dueOn = Date(secondsSince1970: 72988400)
            static let milestones = [MilestoneTests.objectWithRequiredPropertiesFromJSON!, MilestoneTests.objectWithRequiredPropertiesFromJSON!, MilestoneTests.objectWithRequiredPropertiesFromJSON!] // This must match the order and datasources in: JSON.optionals["milestones"]
            static let parentId = 12
            static let startOn = Date(secondsSince1970: 72977000)
            static let startedOn = Date(secondsSince1970: 72977321)
        }

    }

}

extension MilestoneTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.isCompleted.rawValue: Properties.Required.isCompleted,
                Object.JSONKeys.isStarted.rawValue: Properties.Required.isStarted,
                Object.JSONKeys.name.rawValue: Properties.Required.name,
                Object.JSONKeys.projectId.rawValue: Properties.Required.projectId,
                Object.JSONKeys.url.rawValue: Properties.Required.url.absoluteString]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.completedOn.rawValue: Properties.Optional.completedOn.secondsSince1970,
                Object.JSONKeys.description.rawValue: Properties.Optional.description,
                Object.JSONKeys.dueOn.rawValue: Properties.Optional.dueOn.secondsSince1970,
                Object.JSONKeys.milestones.rawValue: [MilestoneTests.requiredJSON, MilestoneTests.requiredJSON, MilestoneTests.requiredJSON], // This must match the order and datasources in: Properties.Optional.milestones
                Object.JSONKeys.parentId.rawValue: Properties.Optional.parentId,
                Object.JSONKeys.startOn.rawValue: Properties.Optional.startOn.secondsSince1970,
                Object.JSONKeys.startedOn.rawValue: Properties.Optional.startedOn.secondsSince1970]
    }

}

// MARK: - Objects

extension MilestoneTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(completedOn: nil,
                      description: nil,
                      dueOn: nil,
                      id: Properties.Required.id,
                      isCompleted: Properties.Required.isCompleted,
                      isStarted: Properties.Required.isStarted,
                      milestones: nil,
                      name: Properties.Required.name,
                      parentId: nil,
                      projectId: Properties.Required.projectId,
                      startOn: nil,
                      startedOn: nil,
                      url: Properties.Required.url)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(completedOn: Properties.Optional.completedOn,
                      description: Properties.Optional.description,
                      dueOn: Properties.Optional.dueOn,
                      id: Properties.Required.id,
                      isCompleted: Properties.Required.isCompleted,
                      isStarted: Properties.Required.isStarted,
                      milestones: Properties.Optional.milestones,
                      name: Properties.Required.name,
                      parentId: Properties.Optional.parentId,
                      projectId: Properties.Required.projectId,
                      startOn: Properties.Optional.startOn,
                      startedOn: Properties.Optional.startedOn,
                      url: Properties.Required.url)
    }

}

// MARK: - Assertions

extension MilestoneTests: AssertEquatable { }

extension MilestoneTests: AssertJSONDeserializing { }

extension MilestoneTests: AssertJSONSerializing { }

extension MilestoneTests: AssertJSONTwoWaySerialization { }

extension MilestoneTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.isCompleted, Properties.Required.isCompleted)
        XCTAssertEqual(object.isStarted, Properties.Required.isStarted)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.projectId, Properties.Required.projectId)
        XCTAssertEqual(object.url, Properties.Required.url)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.completedOn)
            XCTAssertNil(object.description)
            XCTAssertNil(object.dueOn)
            XCTAssertNil(object.milestones)
            XCTAssertNil(object.parentId)
            XCTAssertNil(object.startOn)
            XCTAssertNil(object.startedOn)
        } else {
            XCTAssertNotNil(object.completedOn)
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.dueOn)
            XCTAssertNotNil(object.milestones)
            XCTAssertNotNil(object.parentId)
            XCTAssertNotNil(object.startOn)
            XCTAssertNotNil(object.startedOn)
            XCTAssertEqual(object.completedOn, Properties.Optional.completedOn)
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.dueOn, Properties.Optional.dueOn)
            XCTAssertEqual(object.milestones!, Properties.Optional.milestones)
            XCTAssertEqual(object.parentId, Properties.Optional.parentId)
            XCTAssertEqual(object.startOn, Properties.Optional.startOn)
            XCTAssertEqual(object.startedOn, Properties.Optional.startedOn)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.description = "New Description"
        object.dueOn = Date(secondsSince1970: 90000000)
        object.isCompleted = false
        object.isStarted = false
        object.name = "New Name"
        object.parentId = 9999
        object.startOn = Date(secondsSince1970: 80000000)

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.dueOn, Properties.Optional.dueOn)
        XCTAssertNotEqual(object.isCompleted, Properties.Required.isCompleted)
        XCTAssertNotEqual(object.isStarted, Properties.Required.isStarted)
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertNotEqual(object.parentId, Properties.Optional.parentId)
        XCTAssertNotEqual(object.startOn, Properties.Optional.startOn)

        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.dueOn, Date(secondsSince1970: 90000000))
        XCTAssertEqual(object.isCompleted, false)
        XCTAssertEqual(object.isStarted, false)
        XCTAssertEqual(object.name, "New Name")
        XCTAssertEqual(object.parentId, 9999)
        XCTAssertEqual(object.startOn, Date(secondsSince1970: 80000000))
    }

}

extension MilestoneTests: AssertUpdateRequestJSON { }
