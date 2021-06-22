import XCTest
@testable import QuizTrain

// MARK: - Tests

class TestTests: XCTestCase, ModelTests {

    typealias Object = Test

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

extension TestTests {

    struct Properties {

        struct Required {
            static let caseId = 3405
            static let id = 4
            static let priorityId = 23
            static let runId = 1
            static let statusId = 93
            static let templateId = 8834
            static let title = "Title"
            static let typeId = 738
        }

        struct Optional {
            static let assignedtoId = 345
            static let estimate = "1hr 2min"
            static let estimateForecast = "2hr"
            static let milestoneId = 513
            static let refs = "1,2,3"
        }

    }

}

extension TestTests: CustomFieldsDataProvider { }

extension TestTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.caseId.rawValue: Properties.Required.caseId,
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.priorityId.rawValue: Properties.Required.priorityId,
                Object.JSONKeys.runId.rawValue: Properties.Required.runId,
                Object.JSONKeys.statusId.rawValue: Properties.Required.statusId,
                Object.JSONKeys.templateId.rawValue: Properties.Required.templateId,
                Object.JSONKeys.title.rawValue: Properties.Required.title,
                Object.JSONKeys.typeId.rawValue: Properties.Required.typeId]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.assignedtoId.rawValue: Properties.Optional.assignedtoId,
                Object.JSONKeys.estimate.rawValue: Properties.Optional.estimate,
                Object.JSONKeys.estimateForecast.rawValue: Properties.Optional.estimateForecast,
                Object.JSONKeys.milestoneId.rawValue: Properties.Optional.milestoneId,
                Object.JSONKeys.refs.rawValue: Properties.Optional.refs]
    }

}

// MARK: - Objects

extension TestTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(assignedtoId: nil,
                      caseId: Properties.Required.caseId,
                      estimate: nil,
                      estimateForecast: nil,
                      id: Properties.Required.id,
                      milestoneId: nil,
                      priorityId: Properties.Required.priorityId,
                      refs: nil,
                      runId: Properties.Required.runId,
                      statusId: Properties.Required.statusId,
                      templateId: Properties.Required.templateId,
                      title: Properties.Required.title,
                      typeId: Properties.Required.typeId,
                      customFieldsContainer: emptyCustomFieldsContainer)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(assignedtoId: Properties.Optional.assignedtoId,
                      caseId: Properties.Required.caseId,
                      estimate: Properties.Optional.estimate,
                      estimateForecast: Properties.Optional.estimateForecast,
                      id: Properties.Required.id,
                      milestoneId: Properties.Optional.milestoneId,
                      priorityId: Properties.Required.priorityId,
                      refs: Properties.Optional.refs,
                      runId: Properties.Required.runId,
                      statusId: Properties.Required.statusId,
                      templateId: Properties.Required.templateId,
                      title: Properties.Required.title,
                      typeId: Properties.Required.typeId,
                      customFieldsContainer: customFieldsContainer)
    }

}

// MARK: - Assertions

extension TestTests: AssertCustomFields { }

extension TestTests: AssertEquatable { }

extension TestTests: AssertJSONDeserializing { }

extension TestTests: AssertJSONSerializing { }

extension TestTests: AssertJSONTwoWaySerialization { }

extension TestTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.caseId, Properties.Required.caseId)
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.priorityId, Properties.Required.priorityId)
        XCTAssertEqual(object.runId, Properties.Required.runId)
        XCTAssertEqual(object.statusId, Properties.Required.statusId)
        XCTAssertEqual(object.templateId, Properties.Required.templateId)
        XCTAssertEqual(object.title, Properties.Required.title)
        XCTAssertEqual(object.typeId, Properties.Required.typeId)
    }

    func assertOptionalProperties(in object: Test, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.assignedtoId)
            XCTAssertNil(object.estimate)
            XCTAssertNil(object.estimateForecast)
            XCTAssertNil(object.milestoneId)
            XCTAssertNil(object.refs)
        } else {
            XCTAssertNotNil(object.assignedtoId)
            XCTAssertNotNil(object.estimate)
            XCTAssertNotNil(object.estimateForecast)
            XCTAssertNotNil(object.milestoneId)
            XCTAssertNotNil(object.refs)
            XCTAssertNotNil(object.typeId)
            XCTAssertEqual(object.assignedtoId, Properties.Optional.assignedtoId)
            XCTAssertEqual(object.estimate, Properties.Optional.estimate)
            XCTAssertEqual(object.estimateForecast, Properties.Optional.estimateForecast)
            XCTAssertEqual(object.milestoneId, Properties.Optional.milestoneId)
            XCTAssertEqual(object.refs, Properties.Optional.refs)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
