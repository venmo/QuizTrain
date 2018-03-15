import XCTest
@testable import QuizTrain

// MARK: - Tests

class RunTests: XCTestCase, ModelTests {

    typealias Object = Run

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

extension RunTests {

    struct Properties {

        struct Required {
            static let blockedCount = 2
            static let createdBy = 4
            static let createdOn = Date(secondsSince1970: 72973833)
            static let customStatus1Count = 3
            static let customStatus2Count = 45
            static let customStatus3Count = 78
            static let customStatus4Count = 73
            static let customStatus5Count = 820
            static let customStatus6Count = 1023
            static let customStatus7Count = 567
            static let failedCount = 80
            static let id = 20
            static let includeAll = true
            static let isCompleted = true
            static let name = "Name"
            static let passedCount = 834
            static let projectId = 8
            static let retestCount = 73
            static let untestedCount = 53
            static let url = URL(string: "https://www.testrail.com/")!
        }

        struct Optional {
            static let assignedtoId = 355
            static let completedOn = Date(secondsSince1970: 72988302)
            static let config = "Config"
            static let configIds = [3, 4, 23, 328]
            static let description = "Description"
            static let milestoneId = 33
            static let planId = 2034
            static let suiteId = 36
        }

    }

}

extension RunTests: JSONDataProvider {

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
                Object.JSONKeys.includeAll.rawValue: Properties.Required.includeAll,
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
                Object.JSONKeys.config.rawValue: Properties.Optional.config,
                Object.JSONKeys.configIds.rawValue: Properties.Optional.configIds,
                Object.JSONKeys.description.rawValue: Properties.Optional.description,
                Object.JSONKeys.milestoneId.rawValue: Properties.Optional.milestoneId,
                Object.JSONKeys.planId.rawValue: Properties.Optional.planId,
                Object.JSONKeys.suiteId.rawValue: Properties.Optional.suiteId]
    }

}

// MARK: - Objects

extension RunTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(assignedtoId: nil,
                      blockedCount: Properties.Required.blockedCount,
                      completedOn: nil,
                      config: nil,
                      configIds: nil,
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
                      failedCount: Properties.Required.failedCount,
                      id: Properties.Required.id,
                      includeAll: Properties.Required.includeAll,
                      isCompleted: Properties.Required.isCompleted,
                      milestoneId: nil,
                      name: Properties.Required.name,
                      planId: nil,
                      passedCount: Properties.Required.passedCount,
                      projectId: Properties.Required.projectId,
                      retestCount: Properties.Required.retestCount,
                      suiteId: nil,
                      untestedCount: Properties.Required.untestedCount,
                      url: Properties.Required.url)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(assignedtoId: Properties.Optional.assignedtoId,
                      blockedCount: Properties.Required.blockedCount,
                      completedOn: Properties.Optional.completedOn,
                      config: Properties.Optional.config,
                      configIds: Properties.Optional.configIds,
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
                      failedCount: Properties.Required.failedCount,
                      id: Properties.Required.id,
                      includeAll: Properties.Required.includeAll,
                      isCompleted: Properties.Required.isCompleted,
                      milestoneId: Properties.Optional.milestoneId,
                      name: Properties.Required.name,
                      planId: Properties.Optional.planId,
                      passedCount: Properties.Required.passedCount,
                      projectId: Properties.Required.projectId,
                      retestCount: Properties.Required.retestCount,
                      suiteId: Properties.Optional.suiteId,
                      untestedCount: Properties.Required.untestedCount,
                      url: Properties.Required.url)
    }

}

// MARK: - Assertions

extension RunTests: AssertEquatable { }

extension RunTests: AssertJSONDeserializing { }

extension RunTests: AssertJSONSerializing { }

extension RunTests: AssertJSONTwoWaySerialization { }

extension RunTests: AssertProperties {

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
        XCTAssertEqual(object.includeAll, Properties.Required.includeAll)
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
            XCTAssertNil(object.config)
            XCTAssertNil(object.configIds)
            XCTAssertNil(object.description)
            XCTAssertNil(object.milestoneId)
            XCTAssertNil(object.planId)
            XCTAssertNil(object.suiteId)
        } else {
            XCTAssertNotNil(object.assignedtoId)
            XCTAssertNotNil(object.completedOn)
            XCTAssertNotNil(object.config)
            XCTAssertNotNil(object.configIds)
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.milestoneId)
            XCTAssertNotNil(object.planId)
            XCTAssertNotNil(object.suiteId)
            XCTAssertEqual(object.assignedtoId, Properties.Optional.assignedtoId)
            XCTAssertEqual(object.completedOn, Properties.Optional.completedOn)
            XCTAssertEqual(object.config, Properties.Optional.config)
            XCTAssertEqual(object.configIds!, Properties.Optional.configIds)
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.milestoneId, Properties.Optional.milestoneId)
            XCTAssertEqual(object.planId, Properties.Optional.planId)
            XCTAssertEqual(object.suiteId, Properties.Optional.suiteId)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.description = "New Description"
        object.includeAll = false
        object.milestoneId = 99999
        object.name = "New Name"

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.includeAll, Properties.Required.includeAll)
        XCTAssertNotEqual(object.milestoneId, Properties.Optional.milestoneId)
        XCTAssertNotEqual(object.name, Properties.Required.name)

        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.includeAll, false)
        XCTAssertEqual(object.milestoneId, 99999)
        XCTAssertEqual(object.name, "New Name")
    }

}

extension RunTests: AssertUpdateRequestJSON { }
