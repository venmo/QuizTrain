import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewSuiteTests: XCTestCase, AddModelTests {

    typealias Object = NewSuite

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

extension NewSuiteTests {

    struct Properties {

        struct Required {
            static let name = "Name"
        }

        struct Optional {
            static let description = "Description"
        }

    }

}

// MARK: - Objects

extension NewSuiteTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(description: nil,
                      name: Properties.Required.name)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(description: Properties.Optional.description,
                      name: Properties.Required.name)
    }

}

// MARK: - Assertions

extension NewSuiteTests: AssertAddRequestJSON { }

extension NewSuiteTests: AssertEquatable { }

extension NewSuiteTests: AssertJSONSerializing { }

extension NewSuiteTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.description)
        } else {
            XCTAssertNotNil(object.description)
            XCTAssertEqual(object.description, Properties.Optional.description)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.description = "New Description"
        object.name = "New Name"

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.name, Properties.Required.name)

        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.name, "New Name")
    }

}
