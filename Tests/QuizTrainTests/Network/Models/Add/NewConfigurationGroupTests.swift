import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewConfigurationGroupTests: XCTestCase, AddModelTests {

    typealias Object = NewConfigurationGroup

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

extension NewConfigurationGroupTests {

    struct Properties {

        struct Required {
            static let name = "Name"
        }

        struct Optional { /* none */ }

    }

}

// MARK: - Objects

extension NewConfigurationGroupTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(name: Properties.Required.name)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(name: Properties.Required.name)
    }

}

// MARK: - Assertions

extension NewConfigurationGroupTests: AssertAddRequestJSON { }

extension NewConfigurationGroupTests: AssertEquatable { }

extension NewConfigurationGroupTests: AssertJSONSerializing { }

extension NewConfigurationGroupTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
