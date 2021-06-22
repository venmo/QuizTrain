import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewMilestoneTests: XCTestCase, AddModelTests {

    typealias Object = NewMilestone

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

extension NewMilestoneTests {

    struct Properties {

        struct Required {
            static let name = "Name"
        }

        struct Optional {
            static let description = "Description"
            static let dueOn = Date(secondsSince1970: 2000000)
            static let parentId = 10
            static let startOn = Date(secondsSince1970: 1000000)
        }

    }

}

// MARK: - Objects

extension NewMilestoneTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(description: nil,
                      dueOn: nil,
                      name: Properties.Required.name,
                      parentId: nil,
                      startOn: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(description: Properties.Optional.description,
                      dueOn: Properties.Optional.dueOn,
                      name: Properties.Required.name,
                      parentId: Properties.Optional.parentId,
                      startOn: Properties.Optional.startOn)
    }

}

// MARK: - Assertions

extension NewMilestoneTests: AssertAddRequestJSON { }

extension NewMilestoneTests: AssertEquatable { }

extension NewMilestoneTests: AssertJSONSerializing { }

extension NewMilestoneTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.description)
            XCTAssertNil(object.dueOn)
            XCTAssertNil(object.parentId)
            XCTAssertNil(object.startOn)
        } else {
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.dueOn)
            XCTAssertNotNil(object.parentId)
            XCTAssertNotNil(object.startOn)
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.dueOn, Properties.Optional.dueOn)
            XCTAssertEqual(object.parentId, Properties.Optional.parentId)
            XCTAssertEqual(object.startOn, Properties.Optional.startOn)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.description = "New Description"
        object.dueOn = Date(secondsSince1970: 2999999)
        object.name = "New Name"
        object.parentId = 1000
        object.startOn = Date(secondsSince1970: 3999999)

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.dueOn, Properties.Optional.dueOn)
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertNotEqual(object.parentId, Properties.Optional.parentId)
        XCTAssertNotEqual(object.startOn, Properties.Optional.startOn)

        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.dueOn, Date(secondsSince1970: 2999999))
        XCTAssertEqual(object.name, "New Name")
        XCTAssertEqual(object.parentId, 1000)
        XCTAssertEqual(object.startOn, Date(secondsSince1970: 3999999))
    }

}
