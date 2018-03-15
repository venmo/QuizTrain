import XCTest
@testable import QuizTrain

// MARK: - Tests

class CaseFieldTests: XCTestCase, ModelTests {

    typealias Object = CaseField

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

extension CaseFieldTests {

    struct Properties {

        struct Required {
            static let configs = [ConfigTests.objectWithRequiredAndOptionalPropertiesFromJSON!, ConfigTests.objectWithRequiredPropertiesFromJSON!, ConfigTests.objectWithRequiredAndOptionalPropertiesFromJSON!] // This must match the order and datasources in: JSON.required["configs"]
            static let displayOrder = 10
            static let id = 11
            static let includeAll = true
            static let isActive = true
            static let label = "Label"
            static let name = "Name"
            static let systemName = "System Name"
            static let templateIds = [12, 13, 14, 15, 16]
            static let typeId = CustomFieldType.text
        }

        struct Optional {
            static let description = "Description"
        }

    }

}

extension CaseFieldTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.configs.rawValue: [ConfigTests.requiredAndOptionalJSON, ConfigTests.requiredJSON, ConfigTests.requiredAndOptionalJSON], // This must match the order and datasources in: Properties.Required.configs
                Object.JSONKeys.displayOrder.rawValue: Properties.Required.displayOrder,
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.includeAll.rawValue: Properties.Required.includeAll,
                Object.JSONKeys.isActive.rawValue: Properties.Required.isActive,
                Object.JSONKeys.label.rawValue: Properties.Required.label,
                Object.JSONKeys.name.rawValue: Properties.Required.name,
                Object.JSONKeys.systemName.rawValue: Properties.Required.systemName,
                Object.JSONKeys.templateIds.rawValue: Properties.Required.templateIds,
                Object.JSONKeys.typeId.rawValue: Properties.Required.typeId.rawValue]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.description.rawValue: Properties.Optional.description]
    }

}

// MARK: - Objects

extension CaseFieldTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(configs: Properties.Required.configs,
                      description: nil,
                      displayOrder: Properties.Required.displayOrder,
                      id: Properties.Required.id,
                      includeAll: Properties.Required.includeAll,
                      isActive: Properties.Required.isActive,
                      label: Properties.Required.label,
                      name: Properties.Required.name,
                      systemName: Properties.Required.systemName,
                      templateIds: Properties.Required.templateIds,
                      typeId: Properties.Required.typeId)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(configs: Properties.Required.configs,
                      description: Properties.Optional.description,
                      displayOrder: Properties.Required.displayOrder,
                      id: Properties.Required.id,
                      includeAll: Properties.Required.includeAll,
                      isActive: Properties.Required.isActive,
                      label: Properties.Required.label,
                      name: Properties.Required.name,
                      systemName: Properties.Required.systemName,
                      templateIds: Properties.Required.templateIds,
                      typeId: Properties.Required.typeId)
    }

}

// MARK: - Assertions

extension CaseFieldTests: AssertEquatable { }

extension CaseFieldTests: AssertJSONDeserializing { }

extension CaseFieldTests: AssertJSONSerializing { }

extension CaseFieldTests: AssertJSONTwoWaySerialization { }

extension CaseFieldTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.configs.count, Properties.Required.configs.count)
        XCTAssertEqual(object.displayOrder, Properties.Required.displayOrder)
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.includeAll, Properties.Required.includeAll)
        XCTAssertEqual(object.isActive, Properties.Required.isActive)
        XCTAssertEqual(object.label, Properties.Required.label)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.systemName, Properties.Required.systemName)
        XCTAssertEqual(object.templateIds, Properties.Required.templateIds)
        XCTAssertEqual(object.typeId, Properties.Required.typeId)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.description)
        } else {
            XCTAssertNotNil(object.description)
            XCTAssertEqual(object.description, Properties.Optional.description)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
