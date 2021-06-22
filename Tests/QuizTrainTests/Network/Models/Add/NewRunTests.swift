import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewRunTests: XCTestCase, AddModelTests {

    typealias Object = NewRun

    func testAddRequestJSON() {
        _testAddRequestJSON()
    }

    func testEquatable() {
        _testEquatable()
    }

    func testInit() {
        _testInit()
    }

    func testInitWithOptionalProperties() {
        _testInitWithOptionalProperties()
    }

    func testJSONSerializingSingleObjects() {
        _testJSONSerializingSingleObjects()
    }

    func testJSONSerializingMultipleObjects() {
        _testJSONSerializingMultipleObjects()
    }

    func testVariableProperties() {
        _testVariableProperties()
    }

}

// MARK: - Data

extension NewRunTests {

    struct Properties {

        struct Required {
            static let name = "Name"
        }

        struct Optional {
            static let assignedtoId = 13
            static let caseIds = [10, 11, 12]
            static let description = "Description"
            static let includeAll = true
            static let milestoneId = 14
            static let suiteId = 15
        }

    }

}

// MARK: - Objects

extension NewRunTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(assignedtoId: nil,
                      caseIds: nil,
                      description: nil,
                      includeAll: nil,
                      milestoneId: nil,
                      name: Properties.Required.name,
                      suiteId: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(assignedtoId: Properties.Optional.assignedtoId,
                      caseIds: Properties.Optional.caseIds,
                      description: Properties.Optional.description,
                      includeAll: Properties.Optional.includeAll,
                      milestoneId: Properties.Optional.milestoneId,
                      name: Properties.Required.name,
                      suiteId: Properties.Optional.suiteId)
    }

}

// MARK: - Assertions

extension NewRunTests: AssertAddRequestJSON { }

extension NewRunTests: AssertEquatable { }

extension NewRunTests: AssertJSONSerializing { }

extension NewRunTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.assignedtoId)
            XCTAssertNil(object.caseIds)
            XCTAssertNil(object.description)
            XCTAssertNil(object.includeAll)
            XCTAssertNil(object.milestoneId)
            XCTAssertNil(object.suiteId)
        } else {
            XCTAssertNotNil(object.assignedtoId)
            XCTAssertNotNil(object.caseIds)
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.includeAll)
            XCTAssertNotNil(object.milestoneId)
            XCTAssertNotNil(object.suiteId)
            XCTAssertEqual(object.assignedtoId, Properties.Optional.assignedtoId)
            if let objectCaseIds = object.caseIds { XCTAssertEqual(objectCaseIds, Properties.Optional.caseIds) }
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.includeAll, Properties.Optional.includeAll)
            XCTAssertEqual(object.milestoneId, Properties.Optional.milestoneId)
            XCTAssertEqual(object.suiteId, Properties.Optional.suiteId)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.assignedtoId = 1000
        object.caseIds = [1001, 1002, 1003]
        object.description = "New Description"
        object.includeAll = false
        object.milestoneId = 1004
        object.name = "New Name"
        object.suiteId = 1005

        XCTAssertNotEqual(object.assignedtoId, Properties.Optional.assignedtoId)
        if let objectCaseIds = object.caseIds { XCTAssertNotEqual(objectCaseIds, Properties.Optional.caseIds) }
        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.includeAll, Properties.Optional.includeAll)
        XCTAssertNotEqual(object.milestoneId, Properties.Optional.milestoneId)
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertNotEqual(object.suiteId, Properties.Optional.suiteId)

        XCTAssertEqual(object.assignedtoId, 1000)
        if let objectCaseIds = object.caseIds { XCTAssertEqual(objectCaseIds, [1001, 1002, 1003]) }
        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.includeAll, false)
        XCTAssertEqual(object.milestoneId, 1004)
        XCTAssertEqual(object.name, "New Name")
        XCTAssertEqual(object.suiteId, 1005)
    }

}
