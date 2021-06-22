import XCTest
@testable import QuizTrain

// MARK: - Tests

class UpdatePlanEntryRunsTests: XCTestCase, UpdateModelTests {

    typealias Object = UpdatePlanEntryRuns

    func testUpdateRequestJSON() {
        _testUpdateRequestJSON()
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

extension UpdatePlanEntryRunsTests {

    struct Properties {

        struct Required { /* none */ }

        struct Optional {
            static let assignedtoId = 10
            static let caseIds = [11, 12, 13]
            static let description = "Description"
            static let includeAll = true
        }

    }

}

// MARK: - Objects

extension UpdatePlanEntryRunsTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(assignedtoId: nil,
                      caseIds: nil,
                      description: nil,
                      includeAll: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(assignedtoId: Properties.Optional.assignedtoId,
                      caseIds: Properties.Optional.caseIds,
                      description: Properties.Optional.description,
                      includeAll: Properties.Optional.includeAll)
    }

}

// MARK: - Assertions

extension UpdatePlanEntryRunsTests: AssertUpdateRequestJSON { }

extension UpdatePlanEntryRunsTests: AssertEquatable { }

extension UpdatePlanEntryRunsTests: AssertJSONSerializing { }

extension UpdatePlanEntryRunsTests: AssertProperties {

    func assertRequiredProperties(in object: Object) { /* none */ }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.assignedtoId)
            XCTAssertNil(object.caseIds)
            XCTAssertNil(object.description)
            XCTAssertNil(object.includeAll)
        } else {
            XCTAssertNotNil(object.assignedtoId)
            XCTAssertNotNil(object.caseIds)
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.includeAll)
            XCTAssertEqual(object.assignedtoId, Properties.Optional.assignedtoId)
            XCTAssertEqual(object.caseIds!, Properties.Optional.caseIds)
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.includeAll, Properties.Optional.includeAll)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.assignedtoId = 1000
        object.caseIds = [1001, 1002, 1003]
        object.description = "New Description"
        object.includeAll = false

        XCTAssertNotEqual(object.assignedtoId, Properties.Optional.assignedtoId)
        XCTAssertNotEqual(object.caseIds!, Properties.Optional.caseIds)
        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.includeAll, Properties.Optional.includeAll)

        XCTAssertEqual(object.assignedtoId, 1000)
        XCTAssertEqual(object.caseIds!, [1001, 1002, 1003])
        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.includeAll, false)
    }

}
