import XCTest
@testable import QuizTrain

// MARK: - Tests

class PlanTests: XCTestCase, ModelTests {

    typealias Object = Plan

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

extension PlanTests {

    struct Properties {

        struct Required {
            static let blockedCount = 9
            static let createdBy = 10
            static let createdOn = Date(secondsSince1970: 72973833)
            static let customStatus1Count = 11
            static let customStatus2Count = 12
            static let customStatus3Count = 13
            static let customStatus4Count = 14
            static let customStatus5Count = 15
            static let customStatus6Count = 16
            static let customStatus7Count = 17
            static let failedCount = 18
            static let id = 19
            static let isCompleted = true
            static let name = "Name"
            static let passedCount = 20
            static let projectId = 21
            static let retestCount = 22
            static let untestedCount = 23
            static let url = URL(string: "https://www.testrail.com/")!
        }

        struct Optional {
            static let assignedtoId = 24
            static let completedOn = Date(secondsSince1970: 72988302)
            static let description = "Description"
            static let entries = [Plan_EntryTests.objectWithRequiredAndOptionalPropertiesFromJSON!, Plan_EntryTests.objectWithRequiredPropertiesFromJSON!, Plan_EntryTests.objectWithRequiredAndOptionalPropertiesFromJSON!] // This must match the order and datasources in: JSON.optionals["entries"]
            static let milestoneId = 25
        }

    }

}

extension PlanTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.blockedCount.rawValue: Properties.Required.blockedCount,
                Object.JSONKeys.createdBy.rawValue: Properties.Required.createdBy,
                Object.JSONKeys.createdOn.rawValue: Properties.Required.createdOn.secondsSince1970,
                Object.JSONKeys.customStatus1Count.rawValue: Properties.Required.customStatus1Count,
                Object.JSONKeys.customStatus2Count.rawValue: Properties.Required.customStatus2Count,
                Object.JSONKeys.customStatus3Count.rawValue: Properties.Required.customStatus3Count,
                Object.JSONKeys.customStatus4Count.rawValue: Properties.Required.customStatus4Count,
                Object.JSONKeys.customStatus5Count.rawValue: Properties.Required.customStatus5Count,
                Object.JSONKeys.customStatus6Count.rawValue: Properties.Required.customStatus6Count,
                Object.JSONKeys.customStatus7Count.rawValue: Properties.Required.customStatus7Count,
                Object.JSONKeys.failedCount.rawValue: Properties.Required.failedCount,
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.isCompleted.rawValue: Properties.Required.isCompleted,
                Object.JSONKeys.name.rawValue: Properties.Required.name,
                Object.JSONKeys.passedCount.rawValue: Properties.Required.passedCount,
                Object.JSONKeys.projectId.rawValue: Properties.Required.projectId,
                Object.JSONKeys.retestCount.rawValue: Properties.Required.retestCount,
                Object.JSONKeys.untestedCount.rawValue: Properties.Required.untestedCount,
                Object.JSONKeys.url.rawValue: Properties.Required.url.absoluteString]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.assignedtoId.rawValue: Properties.Optional.assignedtoId,
                Object.JSONKeys.completedOn.rawValue: Properties.Optional.completedOn.secondsSince1970,
                Object.JSONKeys.description.rawValue: Properties.Optional.description,
                Object.JSONKeys.entries.rawValue: [Plan_EntryTests.requiredAndOptionalJSON, Plan_EntryTests.requiredJSON, Plan_EntryTests.requiredAndOptionalJSON], // This must match the order and datasources in: Properties.Optional.entries
                Object.JSONKeys.milestoneId.rawValue: Properties.Optional.milestoneId]
    }

}

// MARK: - Objects

extension PlanTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(assignedtoId: nil,
                      blockedCount: Properties.Required.blockedCount,
                      completedOn: nil,
                      createdBy: Properties.Required.createdBy,
                      createdOn: Properties.Required.createdOn,
                      customStatus1Count: Properties.Required.customStatus1Count,
                      customStatus2Count: Properties.Required.customStatus2Count,
                      customStatus3Count: Properties.Required.customStatus3Count,
                      customStatus4Count: Properties.Required.customStatus4Count,
                      customStatus5Count: Properties.Required.customStatus5Count,
                      customStatus6Count: Properties.Required.customStatus6Count,
                      customStatus7Count: Properties.Required.customStatus7Count,
                      description: nil,
                      entries: nil,
                      failedCount: Properties.Required.failedCount,
                      id: Properties.Required.id,
                      isCompleted: Properties.Required.isCompleted,
                      milestoneId: nil,
                      name: Properties.Required.name,
                      passedCount: Properties.Required.passedCount,
                      projectId: Properties.Required.projectId,
                      retestCount: Properties.Required.retestCount,
                      untestedCount: Properties.Required.untestedCount,
                      url: Properties.Required.url)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(assignedtoId: Properties.Optional.assignedtoId,
                      blockedCount: Properties.Required.blockedCount,
                      completedOn: Properties.Optional.completedOn,
                      createdBy: Properties.Required.createdBy,
                      createdOn: Properties.Required.createdOn,
                      customStatus1Count: Properties.Required.customStatus1Count,
                      customStatus2Count: Properties.Required.customStatus2Count,
                      customStatus3Count: Properties.Required.customStatus3Count,
                      customStatus4Count: Properties.Required.customStatus4Count,
                      customStatus5Count: Properties.Required.customStatus5Count,
                      customStatus6Count: Properties.Required.customStatus6Count,
                      customStatus7Count: Properties.Required.customStatus7Count,
                      description: Properties.Optional.description,
                      entries: Properties.Optional.entries,
                      failedCount: Properties.Required.failedCount,
                      id: Properties.Required.id,
                      isCompleted: Properties.Required.isCompleted,
                      milestoneId: Properties.Optional.milestoneId,
                      name: Properties.Required.name,
                      passedCount: Properties.Required.passedCount,
                      projectId: Properties.Required.projectId,
                      retestCount: Properties.Required.retestCount,
                      untestedCount: Properties.Required.untestedCount,
                      url: Properties.Required.url)
    }

}

// MARK: - Assertions

extension PlanTests: AssertEquatable { }

extension PlanTests: AssertJSONDeserializing { }

extension PlanTests: AssertJSONSerializing { }

extension PlanTests: AssertJSONTwoWaySerialization { }

extension PlanTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.blockedCount, Properties.Required.blockedCount)
        XCTAssertEqual(object.createdBy, Properties.Required.createdBy)
        XCTAssertEqual(object.createdOn, Properties.Required.createdOn)
        XCTAssertEqual(object.customStatus1Count, Properties.Required.customStatus1Count)
        XCTAssertEqual(object.customStatus2Count, Properties.Required.customStatus2Count)
        XCTAssertEqual(object.customStatus3Count, Properties.Required.customStatus3Count)
        XCTAssertEqual(object.customStatus4Count, Properties.Required.customStatus4Count)
        XCTAssertEqual(object.customStatus5Count, Properties.Required.customStatus5Count)
        XCTAssertEqual(object.customStatus6Count, Properties.Required.customStatus6Count)
        XCTAssertEqual(object.customStatus7Count, Properties.Required.customStatus7Count)
        XCTAssertEqual(object.failedCount, Properties.Required.failedCount)
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.isCompleted, Properties.Required.isCompleted)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.passedCount, Properties.Required.passedCount)
        XCTAssertEqual(object.projectId, Properties.Required.projectId)
        XCTAssertEqual(object.retestCount, Properties.Required.retestCount)
        XCTAssertEqual(object.untestedCount, Properties.Required.untestedCount)
        XCTAssertEqual(object.url, Properties.Required.url)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.assignedtoId)
            XCTAssertNil(object.completedOn)
            XCTAssertNil(object.description)
            XCTAssertNil(object.entries)
            XCTAssertNil(object.milestoneId)
        } else {
            XCTAssertNotNil(object.assignedtoId)
            XCTAssertNotNil(object.completedOn)
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.entries)
            XCTAssertNotNil(object.milestoneId)
            XCTAssertEqual(object.assignedtoId, Properties.Optional.assignedtoId)
            XCTAssertEqual(object.completedOn, Properties.Optional.completedOn)
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.entries!, Properties.Optional.entries)
            XCTAssertEqual(object.milestoneId, Properties.Optional.milestoneId)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.description = "New Description"
        object.milestoneId = 9999
        object.name = "New Name"

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.milestoneId, Properties.Optional.milestoneId)
        XCTAssertNotEqual(object.name, Properties.Required.name)

        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.milestoneId, 9999)
        XCTAssertEqual(object.name, "New Name")
    }

}

extension PlanTests: AssertUpdateRequestJSON { }
