import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewTestResultsTests: XCTestCase, AddModelTests, ValidatableTests {

    typealias Object = NewTestResults

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

extension NewTestResultsTests {

    struct Properties {

        struct Required {
            static let results = [NewTestResults_ResultTests.objectWithRequiredAndOptionalProperties, NewTestResults_ResultTests.objectWithRequiredAndOptionalProperties, NewTestResults_ResultTests.objectWithRequiredAndOptionalProperties]
        }

        struct Optional { /* none */ }

    }

}

extension NewTestResultsTests: CustomFieldsDataProvider { }

// MARK: - Objects

extension NewTestResultsTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(results: Properties.Required.results)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(results: Properties.Required.results)
    }

}

extension NewTestResultsTests: ValidatableObjectProvider {

    var validObject: Validatable {
        return objectWithRequiredAndOptionalProperties
    }

    var invalidObject: Validatable {
        return Object(results: [NewTestResults_ResultTests.objectWithRequiredProperties, NewTestResults_ResultTests.objectWithRequiredProperties, NewTestResults_ResultTests.objectWithRequiredProperties])
    }

}

// MARK: - Assertions

extension NewTestResultsTests: AssertAddRequestJSON { }

extension NewTestResultsTests: AssertEquatable { }

extension NewTestResultsTests: AssertJSONSerializing { }

extension NewTestResultsTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.results, Properties.Required.results)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {
        object.results.append(NewTestResults_ResultTests.objectWithRequiredProperties)
        XCTAssertNotEqual(object.results, Properties.Required.results)
        object.results.remove(at: object.results.count - 1)
        XCTAssertEqual(object.results, Properties.Required.results)
    }

}

extension NewTestResultsTests: AssertValidatable { }
