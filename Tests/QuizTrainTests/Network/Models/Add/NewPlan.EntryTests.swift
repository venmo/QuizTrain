import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewPlan_EntryTests: XCTestCase, AddModelTests {

    typealias Object = NewPlan.Entry

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

extension NewPlan_EntryTests {

    struct Properties {

        struct Required {
            static let suiteId = 10
        }

        struct Optional {
            static let assignedtoId = 11
            static let caseIds = [12, 13, 14]
            static let description = "Description"
            static let includeAll = true
            static let name = "Name"
            static let runs = [NewPlan_Entry_RunTests.objectWithRequiredAndOptionalProperties, NewPlan_Entry_RunTests.objectWithRequiredAndOptionalProperties, NewPlan_Entry_RunTests.objectWithRequiredAndOptionalProperties]
        }

    }

}

// MARK: - Objects

extension NewPlan_EntryTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(assignedtoId: nil,
                      caseIds: nil,
                      description: nil,
                      includeAll: nil,
                      name: nil,
                      runs: nil,
                      suiteId: Properties.Required.suiteId)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(assignedtoId: Properties.Optional.assignedtoId,
                      caseIds: Properties.Optional.caseIds,
                      description: Properties.Optional.description,
                      includeAll: Properties.Optional.includeAll,
                      name: Properties.Optional.name,
                      runs: Properties.Optional.runs,
                      suiteId: Properties.Required.suiteId)
    }

}

// MARK: - Assertions

extension NewPlan_EntryTests: AssertAddRequestJSON { }

extension NewPlan_EntryTests: AssertEquatable { }

extension NewPlan_EntryTests: AssertJSONSerializing { }

extension NewPlan_EntryTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.suiteId, Properties.Required.suiteId)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.assignedtoId)
            XCTAssertNil(object.caseIds)
            XCTAssertNil(object.configIds)
            XCTAssertNil(object.description)
            XCTAssertNil(object.includeAll)
            XCTAssertNil(object.name)
            XCTAssertNil(object.runs)
        } else {
            XCTAssertNotNil(object.assignedtoId)
            XCTAssertNotNil(object.caseIds)
            XCTAssertNotNil(object.configIds)
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.includeAll)
            XCTAssertNotNil(object.name)
            XCTAssertNotNil(object.runs)
            XCTAssertEqual(object.assignedtoId, Properties.Optional.assignedtoId)
            if let caseIds = object.caseIds { XCTAssertEqual(caseIds, Properties.Optional.caseIds) }
            if let configIds = object.configIds {
                if let configIdsInRuns = self.configIds(in: Properties.Optional.runs) {
                    XCTAssertEqual(configIds, configIdsInRuns)
                }
            }
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.includeAll, Properties.Optional.includeAll)
            XCTAssertEqual(object.name, Properties.Optional.name)
            if let runs = object.runs { XCTAssertEqual(runs, Properties.Optional.runs) }
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        let initialConfigIds = object.configIds

        object.assignedtoId = 1000
        object.caseIds = [1001, 1002, 1003]
        object.description = "New Description"
        object.includeAll = false
        object.name = "New Name"
        object.runs = [NewPlan_Entry_RunTests.objectWithRequiredProperties, NewPlan_Entry_RunTests.objectWithRequiredProperties]
        object.suiteId = 1004

        XCTAssertNotEqual(object.assignedtoId, Properties.Optional.assignedtoId)
        if let caseIds = object.caseIds { XCTAssertNotEqual(caseIds, Properties.Optional.caseIds) }
        if let configIds = object.configIds, let initialConfigIds = initialConfigIds { XCTAssertNotEqual(configIds, initialConfigIds) }
        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.includeAll, Properties.Optional.includeAll)
        XCTAssertNotEqual(object.name, Properties.Optional.name)
        XCTAssertNotEqual(object.runs!, Properties.Optional.runs)
        if let runs = object.runs { XCTAssertNotEqual(runs, Properties.Optional.runs) }
        XCTAssertNotEqual(object.suiteId, Properties.Required.suiteId)

        XCTAssertEqual(object.assignedtoId, 1000)
        if let caseIds = object.caseIds { XCTAssertEqual(caseIds, [1001, 1002, 1003]) }
        if let configIds = object.configIds {
            if let allRunConfigIds = self.configIds(in: [NewPlan_Entry_RunTests.objectWithRequiredAndOptionalProperties, NewPlan_Entry_RunTests.objectWithRequiredAndOptionalProperties]) {
                XCTAssertEqual(configIds, allRunConfigIds)
            }
        }
        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.includeAll, false)
        XCTAssertEqual(object.name, "New Name")
        if let runs = object.runs { XCTAssertEqual(runs, [NewPlan_Entry_RunTests.objectWithRequiredProperties, NewPlan_Entry_RunTests.objectWithRequiredProperties]) }
        XCTAssertEqual(object.suiteId, 1004)
    }

}

extension NewPlan_EntryTests {

    /*
     Helper to return all configIds from an array of NewPlan.Entry.Run's.
     */
    func configIds(in runs: [NewPlan.Entry.Run]) -> [Int]? {

        var allRunConfigIds = [Int]()
        var allRunConfigIdsAreNil = true

        for run in runs {

            guard let runConfigIds = run.configIds else {
                continue
            }

            allRunConfigIdsAreNil = false
            allRunConfigIds.append(contentsOf: runConfigIds)
        }

        if allRunConfigIdsAreNil {
            return nil
        }

        allRunConfigIds = Array(Set(allRunConfigIds)) // Remove duplicates
        allRunConfigIds.sort() // configIds is sorted by default

        return allRunConfigIds
    }

}
