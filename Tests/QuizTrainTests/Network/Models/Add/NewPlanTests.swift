import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewPlanTests: XCTestCase, AddModelTests {

    typealias Object = NewPlan

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

extension NewPlanTests {

    struct Properties {

        struct Required {
            static let name = "Name"
        }

        struct Optional {
            static let description = "Description"
            static let entries = [NewPlan_EntryTests.objectWithRequiredAndOptionalProperties, NewPlan_EntryTests.objectWithRequiredAndOptionalProperties, NewPlan_EntryTests.objectWithRequiredAndOptionalProperties]
            static let milestoneId = 10
        }

    }

}

// MARK: - Objects

extension NewPlanTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(description: nil,
                      entries: nil,
                      milestoneId: nil,
                      name: Properties.Required.name)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(description: Properties.Optional.description,
                      entries: Properties.Optional.entries,
                      milestoneId: Properties.Optional.milestoneId,
                      name: Properties.Required.name)
    }

}

// MARK: - Assertions

extension NewPlanTests: AssertAddRequestJSON { }

extension NewPlanTests: AssertEquatable { }

extension NewPlanTests: AssertJSONSerializing { }

extension NewPlanTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.description)
            XCTAssertNil(object.entries)
            XCTAssertNil(object.milestoneId)
        } else {
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.entries)
            XCTAssertNotNil(object.milestoneId)
            XCTAssertEqual(object.description, Properties.Optional.description)
            if let entries = object.entries { XCTAssertEqual(entries, Properties.Optional.entries) }
            XCTAssertEqual(object.milestoneId, Properties.Optional.milestoneId)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.description = "New Description"
        object.entries = [NewPlan_EntryTests.objectWithRequiredAndOptionalProperties, NewPlan_EntryTests.objectWithRequiredAndOptionalProperties]
        object.milestoneId = 1000
        object.name = "New Name"

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        if let entries = object.entries { XCTAssertNotEqual(entries, Properties.Optional.entries) }
        XCTAssertNotEqual(object.milestoneId, Properties.Optional.milestoneId)
        XCTAssertNotEqual(object.name, Properties.Required.name)

        XCTAssertEqual(object.description, "New Description")
        if let entries = object.entries { XCTAssertEqual(entries, [NewPlan_EntryTests.objectWithRequiredAndOptionalProperties, NewPlan_EntryTests.objectWithRequiredAndOptionalProperties]) }
        XCTAssertEqual(object.milestoneId, 1000)
        XCTAssertEqual(object.name, "New Name")
    }

}
