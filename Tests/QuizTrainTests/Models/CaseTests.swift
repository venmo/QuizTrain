import XCTest
@testable import QuizTrain

// MARK: - Tests

class CaseTests: XCTestCase, ModelTests {

    typealias Object = Case

    func testEquatable() {
        _testEquatable()
    }

    func testInit() {
        _testInit()
    }

    func testInitWithOptionalProperties() {
        _testInitWithOptionalProperties()
    }

    func testJSONDeserializing() {
        _testJSONDeserializing()
    }

    func testJSONDeserializingWithOptionalProperties() {
        _testJSONDeserializingWithOptionalProperties()
    }

    func testJSONDeserializingASingleObject() {
        _testJSONDeserializingASingleObject()
    }

    func testJSONDeserializingMultipleObjects() {
        _testJSONDeserializingMultipleObjects()
    }

    func testJSONDeserializingASingleObjectMissingRequiredProperties() {
        _testJSONDeserializingASingleObjectMissingRequiredProperties()
    }

    func testJSONDeserializingMultipleObjectsMissingRequiredProperties() {
        _testJSONDeserializingMultipleObjectsMissingRequiredProperties()
    }

    func testJSONSerializingSingleObjects() {
        _testJSONSerializingSingleObjects()
    }

    func testJSONSerializingMultipleObjects() {
        _testJSONSerializingMultipleObjects()
    }

    func testJSONTwoWaySerializationForSingleItems() {
        _testJSONTwoWaySerializationForSingleItems()
    }

    func testJSONTwoWaySerializationForMultipleItems() {
        _testJSONTwoWaySerializationForMultipleItems()
    }

    func testVariableProperties() {
        _testVariableProperties()
    }

    func testUpdateRequestJSON() {
        _testUpdateRequestJSON()
    }

}

// MARK: - Data

extension CaseTests {

    struct Properties {

        struct Required {
            static let createdBy = 10
            static let createdOn = Date(secondsSince1970: 72973833)
            static let id = 11
            static let priorityId = 12
            static let templateId = 13
            static let title = "Name"
            static let typeId = 14
            static let updatedBy = 15
            static let updatedOn = Date(secondsSince1970: 72988400)
        }

        struct Optional {
            static let estimate = "2hr, 3min"
            static let estimateForecast = "3hr"
            static let milestoneId = 16
            static let refs = "1,2,3"
            static let sectionId = 17
            static let suiteId = 18
        }

    }

}

extension CaseTests: CustomFieldsDataProvider { }

extension CaseTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.createdBy.rawValue: Properties.Required.createdBy,
                Object.JSONKeys.createdOn.rawValue: Properties.Required.createdOn.secondsSince1970,
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.priorityId.rawValue: Properties.Required.priorityId,
                Object.JSONKeys.templateId.rawValue: Properties.Required.templateId,
                Object.JSONKeys.title.rawValue: Properties.Required.title,
                Object.JSONKeys.typeId.rawValue: Properties.Required.typeId,
                Object.JSONKeys.updatedBy.rawValue: Properties.Required.updatedBy,
                Object.JSONKeys.updatedOn.rawValue: Properties.Required.updatedOn.secondsSince1970]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.estimate.rawValue: Properties.Optional.estimate,
                Object.JSONKeys.estimateForecast.rawValue: Properties.Optional.estimateForecast,
                Object.JSONKeys.milestoneId.rawValue: Properties.Optional.milestoneId,
                Object.JSONKeys.refs.rawValue: Properties.Optional.refs,
                Object.JSONKeys.sectionId.rawValue: Properties.Optional.sectionId,
                Object.JSONKeys.suiteId.rawValue: Properties.Optional.suiteId]
    }

}

// MARK: - Objects

extension CaseTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(createdBy: Properties.Required.createdBy,
                      createdOn: Properties.Required.createdOn,
                      estimate: nil,
                      estimateForecast: nil,
                      id: Properties.Required.id,
                      milestoneId: nil,
                      priorityId: Properties.Required.priorityId,
                      refs: nil,
                      sectionId: nil,
                      suiteId: nil,
                      templateId: Properties.Required.templateId,
                      title: Properties.Required.title,
                      typeId: Properties.Required.typeId,
                      updatedBy: Properties.Required.updatedBy,
                      updatedOn: Properties.Required.updatedOn,
                      customFieldsContainer: emptyCustomFieldsContainer)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(createdBy: Properties.Required.createdBy,
                      createdOn: Properties.Required.createdOn,
                      estimate: Properties.Optional.estimate,
                      estimateForecast: Properties.Optional.estimateForecast,
                      id: Properties.Required.id,
                      milestoneId: Properties.Optional.milestoneId,
                      priorityId: Properties.Required.priorityId,
                      refs: Properties.Optional.refs,
                      sectionId: Properties.Optional.sectionId,
                      suiteId: Properties.Optional.suiteId,
                      templateId: Properties.Required.templateId,
                      title: Properties.Required.title,
                      typeId: Properties.Required.typeId,
                      updatedBy: Properties.Required.updatedBy,
                      updatedOn: Properties.Required.updatedOn,
                      customFieldsContainer: customFieldsContainer)
    }

}

// MARK: - Assertions

extension CaseTests: AssertCustomFields { }

extension CaseTests: AssertEquatable { }

extension CaseTests: AssertJSONDeserializing { }

extension CaseTests: AssertJSONSerializing { }

extension CaseTests: AssertJSONTwoWaySerialization { }

extension CaseTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.createdBy, Properties.Required.createdBy)
        XCTAssertEqual(object.createdOn, Properties.Required.createdOn)
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.priorityId, Properties.Required.priorityId)
        XCTAssertEqual(object.templateId, Properties.Required.templateId)
        XCTAssertEqual(object.title, Properties.Required.title)
        XCTAssertEqual(object.typeId, Properties.Required.typeId)
        XCTAssertEqual(object.updatedBy, Properties.Required.updatedBy)
        XCTAssertEqual(object.updatedOn, Properties.Required.updatedOn)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.estimate)
            XCTAssertNil(object.estimateForecast)
            XCTAssertNil(object.milestoneId)
            XCTAssertNil(object.refs)
            XCTAssertNil(object.sectionId)
            XCTAssertNil(object.suiteId)
        } else {
            XCTAssertNotNil(object.estimate)
            XCTAssertNotNil(object.estimateForecast)
            XCTAssertNotNil(object.milestoneId)
            XCTAssertNotNil(object.refs)
            XCTAssertNotNil(object.sectionId)
            XCTAssertNotNil(object.suiteId)
            XCTAssertEqual(object.estimate, Properties.Optional.estimate)
            XCTAssertEqual(object.estimateForecast, Properties.Optional.estimateForecast)
            XCTAssertEqual(object.milestoneId, Properties.Optional.milestoneId)
            XCTAssertEqual(object.refs, Properties.Optional.refs)
            XCTAssertEqual(object.sectionId, Properties.Optional.sectionId)
            XCTAssertEqual(object.suiteId, Properties.Optional.suiteId)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        // Properties

        object.estimate = "New Estimate"
        object.milestoneId = 999
        object.priorityId = 9999
        object.refs = "9,9,9"
        object.templateId = 99999
        object.title = "New Title"
        object.typeId = 999999

        XCTAssertNotEqual(object.estimate, Properties.Optional.estimate)
        XCTAssertNotEqual(object.milestoneId, Properties.Optional.milestoneId)
        XCTAssertNotEqual(object.priorityId, Properties.Required.priorityId)
        XCTAssertNotEqual(object.refs, Properties.Optional.refs)
        XCTAssertNotEqual(object.templateId, Properties.Required.templateId)
        XCTAssertNotEqual(object.title, Properties.Required.title)
        XCTAssertNotEqual(object.typeId, Properties.Required.typeId)
        XCTAssertEqual(object.estimate, "New Estimate")
        XCTAssertEqual(object.milestoneId, 999)
        XCTAssertEqual(object.priorityId, 9999)
        XCTAssertEqual(object.refs, "9,9,9")
        XCTAssertEqual(object.templateId, 99999)
        XCTAssertEqual(object.title, "New Title")
        XCTAssertEqual(object.typeId, 999999)

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

extension CaseTests: AssertUpdateRequestJSON { }
