import XCTest
@testable import QuizTrain

// MARK: - Tests

class ResultTests: XCTestCase, ModelTests {

    typealias Object = Result

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

extension ResultTests {

    struct Properties {

        struct Required {
            static let createdBy = 67
            static let createdOn = Date(secondsSince1970: 72973833)
            static let id = 972
            static let testId = 7
        }

        struct Optional {
            static let assignedtoId = 47
            static let comment = "Comment"
            static let defects = "Defects"
            static let elapsed = "4hr, 31min"
            static let statusId = 3
            static let version = "1.2.3"
        }

    }

}

extension ResultTests: CustomFieldsDataProvider { }

extension ResultTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.createdBy.rawValue: Properties.Required.createdBy,
                Object.JSONKeys.createdOn.rawValue: Properties.Required.createdOn.secondsSince1970,
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.testId.rawValue: Properties.Required.testId]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.assignedtoId.rawValue: Properties.Optional.assignedtoId,
                Object.JSONKeys.comment.rawValue: Properties.Optional.comment,
                Object.JSONKeys.defects.rawValue: Properties.Optional.defects,
                Object.JSONKeys.elapsed.rawValue: Properties.Optional.elapsed,
                Object.JSONKeys.statusId.rawValue: Properties.Optional.statusId,
                Object.JSONKeys.version.rawValue: Properties.Optional.version]
    }

}

// MARK: - Objects

extension ResultTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(assignedtoId: nil,
                      comment: nil,
                      createdBy: Properties.Required.createdBy,
                      createdOn: Properties.Required.createdOn,
                      defects: nil,
                      elapsed: nil,
                      id: Properties.Required.id,
                      statusId: nil,
                      testId: Properties.Required.testId,
                      version: nil,
                      customFieldsContainer: emptyCustomFieldsContainer)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(assignedtoId: Properties.Optional.assignedtoId,
                      comment: Properties.Optional.comment,
                      createdBy: Properties.Required.createdBy,
                      createdOn: Properties.Required.createdOn,
                      defects: Properties.Optional.defects,
                      elapsed: Properties.Optional.elapsed,
                      id: Properties.Required.id,
                      statusId: Properties.Optional.statusId,
                      testId: Properties.Required.testId,
                      version: Properties.Optional.version,
                      customFieldsContainer: customFieldsContainer)
    }

}

// MARK: - Assertions

extension ResultTests: AssertCustomFields { }

extension ResultTests: AssertEquatable { }

extension ResultTests: AssertJSONDeserializing { }

extension ResultTests: AssertJSONSerializing { }

extension ResultTests: AssertJSONTwoWaySerialization { }

extension ResultTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.createdBy, Properties.Required.createdBy)
        XCTAssertEqual(object.createdOn, Properties.Required.createdOn)
        XCTAssertEqual(object.id, Properties.Required.id)
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
        } else {
            XCTAssertNotNil(object.assignedtoId)
            XCTAssertNotNil(object.comment)
            XCTAssertNotNil(object.defects)
            XCTAssertNotNil(object.elapsed)
            XCTAssertNotNil(object.statusId)
            XCTAssertNotNil(object.version)
            XCTAssertEqual(object.assignedtoId, Properties.Optional.assignedtoId)
            XCTAssertEqual(object.comment, Properties.Optional.comment)
            XCTAssertEqual(object.defects, Properties.Optional.defects)
            XCTAssertEqual(object.elapsed, Properties.Optional.elapsed)
            XCTAssertEqual(object.statusId, Properties.Optional.statusId)
            XCTAssertEqual(object.version, Properties.Optional.version)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
