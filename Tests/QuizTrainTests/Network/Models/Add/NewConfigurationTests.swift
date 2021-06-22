import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewConfigurationTests: XCTestCase, AddModelTests {

    typealias Object = NewConfiguration

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

extension NewConfigurationTests {

    struct Properties {

        struct Required {
            static let name = "Name"
        }

        struct Optional { /* none */ }

    }

}

// MARK: - Objects

extension NewConfigurationTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(name: Properties.Required.name)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(name: Properties.Required.name)
    }

}

// MARK: - Assertions

extension NewConfigurationTests: AssertAddRequestJSON { }

extension NewConfigurationTests: AssertEquatable { }

extension NewConfigurationTests: AssertJSONSerializing { }

extension NewConfigurationTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.name, Properties.Required.name)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
