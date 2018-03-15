import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewSectionTests: XCTestCase, AddModelTests {

    typealias Object = NewSection

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

extension NewSectionTests {

    struct Properties {

        struct Required {
            static let name = "Name"
        }

        struct Optional {
            static let description = "Description"
            static let parentId = 10
            static let suiteId = 11
        }

    }

}

// MARK: - Objects

extension NewSectionTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(description: nil,
                      name: Properties.Required.name,
                      parentId: nil,
                      suiteId: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(description: Properties.Optional.description,
                      name: Properties.Required.name,
                      parentId: Properties.Optional.parentId,
                      suiteId: Properties.Optional.suiteId)
    }

}

// MARK: - Assertions

extension NewSectionTests: AssertAddRequestJSON { }

extension NewSectionTests: AssertEquatable { }

extension NewSectionTests: AssertJSONSerializing { }

extension NewSectionTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.description)
            XCTAssertNil(object.parentId)
            XCTAssertNil(object.suiteId)
        } else {
            XCTAssertNotNil(object.description)
            XCTAssertNotNil(object.parentId)
            XCTAssertNotNil(object.suiteId)
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(object.parentId, Properties.Optional.parentId)
            XCTAssertEqual(object.suiteId, Properties.Optional.suiteId)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.description = "New Description"
        object.name = "New Name"
        object.parentId = 1000
        object.suiteId = 1001

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertNotEqual(object.parentId, Properties.Optional.parentId)
        XCTAssertNotEqual(object.suiteId, Properties.Optional.suiteId)

        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.name, "New Name")
        XCTAssertEqual(object.parentId, 1000)
        XCTAssertEqual(object.suiteId, 1001)
    }

}
