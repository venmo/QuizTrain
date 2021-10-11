import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewCaseResultsTests: XCTestCase, AddModelTests, ValidatableTests {

    typealias Object = NewCaseResults

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

    func testIsValid() {
        _testIsValid()
    }

    func testIsInvalid() {
        _testIsInvalid()
    }

}

// MARK: - Data

extension NewCaseResultsTests {

    struct Properties {

        struct Required {
            static let results = [NewCaseResults_ResultTests.objectWithRequiredAndOptionalProperties, NewCaseResults_ResultTests.objectWithRequiredAndOptionalProperties, NewCaseResults_ResultTests.objectWithRequiredAndOptionalProperties]
        }

        struct Optional { /* none */ }

    }

}

extension NewCaseResultsTests: CustomFieldsDataProvider { }

// MARK: - Objects

extension NewCaseResultsTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(results: Properties.Required.results)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(results: Properties.Required.results)
    }

}

extension NewCaseResultsTests: ValidatableObjectProvider {

    var validObject: Validatable {
        return objectWithRequiredAndOptionalProperties
    }

    var invalidObject: Validatable {
        return Object(results: [NewCaseResults_ResultTests.objectWithRequiredProperties, NewCaseResults_ResultTests.objectWithRequiredProperties, NewCaseResults_ResultTests.objectWithRequiredProperties])
    }

}

// MARK: - Assertions

extension NewCaseResultsTests: AssertAddRequestJSON { }

extension NewCaseResultsTests: AssertEquatable { }

extension NewCaseResultsTests: AssertJSONSerializing { }

extension NewCaseResultsTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.results, Properties.Required.results)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {
        object.results.append(NewCaseResults_ResultTests.objectWithRequiredProperties)
        XCTAssertNotEqual(object.results, Properties.Required.results)
        object.results.remove(at: object.results.count - 1)
        XCTAssertEqual(object.results, Properties.Required.results)
    }

}

extension NewCaseResultsTests: AssertValidatable { }
