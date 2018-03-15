import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewTestResults_ResultTests: XCTestCase, AddModelTests, ValidatableTests {

    typealias Object = NewTestResults.Result

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

extension NewTestResults_ResultTests {

    struct Properties {

        struct Required {
            static let testId = 10
        }

        struct Optional {
            static let assignedtoId = 11
            static let comment = "Comment"
            static let defects = "Defects"
            static let elapsed = "4hr, 31min"
            static let statusId = 12
            static let version = "1.2.3"
            static let customFields = NewTestResults_ResultTests.customFields
        }

    }

}

extension NewTestResults_ResultTests: CustomFieldsDataProvider { }

// MARK: - Objects

extension NewTestResults_ResultTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(assignedtoId: nil,
                      comment: nil,
                      defects: nil,
                      elapsed: nil,
                      statusId: nil,
                      testId: Properties.Required.testId,
                      version: nil,
                      customFields: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(assignedtoId: Properties.Optional.assignedtoId,
                      comment: Properties.Optional.comment,
                      defects: Properties.Optional.defects,
                      elapsed: Properties.Optional.elapsed,
                      statusId: Properties.Optional.statusId,
                      testId: Properties.Required.testId,
                      version: Properties.Optional.version,
                      customFields: Properties.Optional.customFields)
    }

}

extension NewTestResults_ResultTests: ValidatableObjectProvider {

    var validObject: Validatable {
        return objectWithRequiredAndOptionalProperties
    }

    var invalidObject: Validatable {
        var object = objectWithRequiredAndOptionalProperties
        object.assignedtoId = nil
        object.comment = nil
        object.statusId = nil
        return object
    }

}

// MARK: - Assertions

extension NewTestResults_ResultTests: AssertAddRequestJSON { }

extension NewTestResults_ResultTests: AssertCustomFields { }

extension NewTestResults_ResultTests: AssertEquatable { }

extension NewTestResults_ResultTests: AssertJSONSerializing { }

extension NewTestResults_ResultTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.testId, Properties.Required.testId)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.assignedtoId)
            XCTAssertNil(object.comment)
            XCTAssertNil(object.defects)
            XCTAssertNil(object.elapsed)
            XCTAssertNil(object.statusId)
            XCTAssertNil(object.version)
            XCTAssertTrue(object.customFields.isEmpty)
        } else {
            XCTAssertNotNil(object.assignedtoId)
            XCTAssertNotNil(object.comment)
            XCTAssertNotNil(object.defects)
            XCTAssertNotNil(object.elapsed)
            XCTAssertNotNil(object.statusId)
            XCTAssertNotNil(object.version)
            XCTAssertNotNil(object.customFields)
            XCTAssertEqual(object.assignedtoId, Properties.Optional.assignedtoId)
            XCTAssertEqual(object.comment, Properties.Optional.comment)
            XCTAssertEqual(object.defects, Properties.Optional.defects)
            XCTAssertEqual(object.elapsed, Properties.Optional.elapsed)
            XCTAssertEqual(object.statusId, Properties.Optional.statusId)
            XCTAssertEqual(object.version, Properties.Optional.version)
            XCTAssertEqual(object.customFields.count, Properties.Optional.customFields.count)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        // Properties

        object.assignedtoId = 1000
        object.comment = "New Comment"
        object.defects = "New Defects"
        object.elapsed = "99hr, 99min"
        object.version = "4.5.6"
        object.statusId = 1001
        object.testId = 1002
        object.customFields = NewTestResults_ResultTests.emptyCustomFields

        XCTAssertNotEqual(object.assignedtoId, Properties.Optional.assignedtoId)
        XCTAssertNotEqual(object.comment, Properties.Optional.comment)
        XCTAssertNotEqual(object.defects, Properties.Optional.defects)
        XCTAssertNotEqual(object.elapsed, Properties.Optional.elapsed)
        XCTAssertNotEqual(object.version, Properties.Optional.version)
        XCTAssertNotEqual(object.statusId, Properties.Optional.statusId)
        XCTAssertNotEqual(object.testId, Properties.Required.testId)
        XCTAssertNotEqual(object.customFields.count, Properties.Optional.customFields.count)

        XCTAssertEqual(object.assignedtoId, 1000)
        XCTAssertEqual(object.comment, "New Comment")
        XCTAssertEqual(object.defects, "New Defects")
        XCTAssertEqual(object.elapsed, "99hr, 99min")
        XCTAssertEqual(object.version, "4.5.6")
        XCTAssertEqual(object.statusId, 1001)
        XCTAssertEqual(object.testId, 1002)
        XCTAssertEqual(object.customFields.count, NewTestResults_ResultTests.emptyCustomFields.count)

        // Custom Fields

        let customFieldsCount = object.customFields.count

        object.customFields["custom_field_test01"] = "Custom Field Test 01"
        object.customFields["custom_field_test02"] = 9000
        object.customFields["custom_field_test03"] = -8.0
        object.customFields["invalid_custom_field_test04"] = "This should not be added."

        XCTAssertNotNil(object.customFields["custom_field_test01"])
        XCTAssertNotNil(object.customFields["custom_field_test02"])
        XCTAssertNotNil(object.customFields["custom_field_test03"])
        XCTAssertNil(object.customFields["invalid_custom_field_test04"])

        XCTAssertEqual(object.customFields["custom_field_test01"] as! String, "Custom Field Test 01")
        XCTAssertEqual(object.customFields["custom_field_test02"] as! Int, 9000)
        XCTAssertEqual(object.customFields["custom_field_test03"] as! Double, -8.0)

        XCTAssertEqual(object.customFields.count, customFieldsCount + 3)

        object.customFields.removeValue(forKey: "custom_field_test01")

        XCTAssertNil(object.customFields["custom_field_test01"])
        XCTAssertEqual(object.customFields.count, customFieldsCount + 2)
    }

}

extension NewTestResults_ResultTests: AssertValidatable { }
