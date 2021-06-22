import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewPlan_Entry_RunTests: XCTestCase, AddModelTests {

    typealias Object = NewPlan.Entry.Run

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

extension NewPlan_Entry_RunTests {

    struct Properties {

        struct Required { /* none */ }

        struct Optional {
            static let assignedtoId: Int = 1
            static let caseIds: [Int] = [2, 3, 4]
            static let configIds: [Int] = [5, 6]
            static let description: String = "Description"
            static let includeAll: Bool = false
            static let milestoneId: Int = 7
            static let name: String = "Name"
            static let suiteId: Int = 8
        }

    }

}

// MARK: - Objects

extension NewPlan_Entry_RunTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(assignedtoId: nil,
                      caseIds: nil,
                      configIds: nil,
                      description: nil,
                      includeAll: nil,
                      milestoneId: nil,
                      name: nil,
                      suiteId: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(assignedtoId: Properties.Optional.assignedtoId,
                      caseIds: Properties.Optional.caseIds,
                      configIds: Properties.Optional.configIds,
                      description: Properties.Optional.description,
                      includeAll: Properties.Optional.includeAll,
                      milestoneId: Properties.Optional.milestoneId,
                      name: Properties.Optional.name,
                      suiteId: Properties.Optional.suiteId)
    }

}

// MARK: - Assertions

extension NewPlan_Entry_RunTests: AssertAddRequestJSON { }

extension NewPlan_Entry_RunTests: AssertEquatable { }

extension NewPlan_Entry_RunTests: AssertJSONSerializing { }

extension NewPlan_Entry_RunTests: AssertProperties {

    func assertRequiredProperties(in object: Object) { /* none */ }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.assignedtoId)
            XCTAssertNil(object.caseIds)
            XCTAssertNil(object.configIds)
            XCTAssertNil(object.description)
            XCTAssertNil(object.includeAll)
            XCTAssertNil(object.milestoneId)
            XCTAssertNil(object.name)
            XCTAssertNil(object.suiteId)
        } else {
            XCTAssertNotNil(object.assignedtoId)
            XCTAssertNotNil(object.caseIds)
            XCTAssertNotNil(object.configIds)
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.includeAll)
            XCTAssertNotNil(object.milestoneId)
            XCTAssertNotNil(object.name)
            XCTAssertNotNil(object.suiteId)
            XCTAssertEqual(object.assignedtoId, Properties.Optional.assignedtoId)
            if let caseIds = object.caseIds { XCTAssertEqual(caseIds, Properties.Optional.caseIds) }
            if let configIds = object.configIds { XCTAssertEqual(configIds, Properties.Optional.configIds) }
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.includeAll, Properties.Optional.includeAll)
            XCTAssertEqual(object.milestoneId, Properties.Optional.milestoneId)
            XCTAssertEqual(object.name, Properties.Optional.name)
            XCTAssertEqual(object.suiteId, Properties.Optional.suiteId)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.assignedtoId = 1000
        object.caseIds = [1001, 1002, 1003]
        object.configIds = [1004, 1005]
        object.description = "New Description"
        object.includeAll = true
        object.milestoneId = 1006
        object.name = "New Name"
        object.suiteId = 1007

        XCTAssertNotEqual(object.assignedtoId, Properties.Optional.assignedtoId)
        if let caseIds = object.caseIds { XCTAssertNotEqual(caseIds, Properties.Optional.caseIds) }
        if let configIds = object.configIds { XCTAssertNotEqual(configIds, Properties.Optional.configIds) }
        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.includeAll, Properties.Optional.includeAll)
        XCTAssertNotEqual(object.name, Properties.Optional.name)
        XCTAssertNotEqual(object.suiteId, Properties.Optional.suiteId)

        XCTAssertEqual(object.assignedtoId, 1000)
        if let caseIds = object.caseIds { XCTAssertEqual(caseIds, [1001, 1002, 1003]) }
        if let configIds = object.configIds { XCTAssertEqual(configIds, [1004, 1005]) }
        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.includeAll, true)
        XCTAssertEqual(object.name, "New Name")
        XCTAssertEqual(object.suiteId, 1007)
    }

}
