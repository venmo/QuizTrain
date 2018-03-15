import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewCaseTests: XCTestCase, AddModelTests {

    typealias Object = NewCase

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

extension NewCaseTests {

    struct Properties {

        struct Required {
            static let title = "Title"
        }

        struct Optional {
            static let estimate = "2hr, 3min"
            static let milestoneId = 10
            static let priorityId = 11
            static let refs = "1,2,3"
            static let templateId = 12
            static let typeId = 13
            static let customFields = NewCaseTests.customFields
        }

    }

}

extension NewCaseTests: CustomFieldsDataProvider { }

// MARK: - Objects

extension NewCaseTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(estimate: nil,
                      milestoneId: nil,
                      priorityId: nil,
                      refs: nil,
                      templateId: nil,
                      title: Properties.Required.title,
                      typeId: nil,
                      customFields: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(estimate: Properties.Optional.estimate,
                      milestoneId: Properties.Optional.milestoneId,
                      priorityId: Properties.Optional.priorityId,
                      refs: Properties.Optional.refs,
                      templateId: Properties.Optional.templateId,
                      title: Properties.Required.title,
                      typeId: Properties.Optional.typeId,
                      customFields: Properties.Optional.customFields)
    }

}

// MARK: - Assertions

extension NewCaseTests: AssertAddRequestJSON { }

extension NewCaseTests: AssertCustomFields { }

extension NewCaseTests: AssertEquatable { }

extension NewCaseTests: AssertJSONSerializing { }

extension NewCaseTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.title, Properties.Required.title)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.estimate)
            XCTAssertNil(object.milestoneId)
            XCTAssertNil(object.priorityId)
            XCTAssertNil(object.refs)
            XCTAssertNil(object.templateId)
            XCTAssertNil(object.typeId)
            XCTAssertTrue(object.customFields.isEmpty)
        } else {
            XCTAssertNotNil(object.estimate)
            XCTAssertNotNil(object.milestoneId)
            XCTAssertNotNil(object.priorityId)
            XCTAssertNotNil(object.refs)
            XCTAssertNotNil(object.templateId)
            XCTAssertNotNil(object.typeId)
            XCTAssertNotNil(object.customFields)
            XCTAssertEqual(object.estimate, Properties.Optional.estimate)
            XCTAssertEqual(object.milestoneId, Properties.Optional.milestoneId)
            XCTAssertEqual(object.priorityId, Properties.Optional.priorityId)
            XCTAssertEqual(object.refs, Properties.Optional.refs)
            XCTAssertEqual(object.templateId, Properties.Optional.templateId)
            XCTAssertEqual(object.typeId, Properties.Optional.typeId)
            XCTAssertEqual(object.customFields.count, Properties.Optional.customFields.count)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        // Properties

        object.estimate = "New Estimate"
        object.milestoneId = 1000
        object.priorityId = 1001
        object.refs = "4,5,6"
        object.title = "New Title"
        object.templateId = 1002
        object.typeId = 1003
        object.customFields = NewCaseTests.emptyCustomFields

        XCTAssertNotEqual(object.estimate, Properties.Optional.estimate)
        XCTAssertNotEqual(object.milestoneId, Properties.Optional.milestoneId)
        XCTAssertNotEqual(object.priorityId, Properties.Optional.priorityId)
        XCTAssertNotEqual(object.refs, Properties.Optional.refs)
        XCTAssertNotEqual(object.title, Properties.Required.title)
        XCTAssertNotEqual(object.templateId, Properties.Optional.templateId)
        XCTAssertNotEqual(object.typeId, Properties.Optional.typeId)
        XCTAssertNotEqual(object.customFields.count, Properties.Optional.customFields.count)

        XCTAssertEqual(object.estimate, "New Estimate")
        XCTAssertEqual(object.milestoneId, 1000)
        XCTAssertEqual(object.priorityId, 1001)
        XCTAssertEqual(object.refs, "4,5,6")
        XCTAssertEqual(object.title, "New Title")
        XCTAssertEqual(object.templateId, 1002)
        XCTAssertEqual(object.typeId, 1003)

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
