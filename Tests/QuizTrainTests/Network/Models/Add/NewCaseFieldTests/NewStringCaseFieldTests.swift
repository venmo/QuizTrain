import XCTest
@testable import QuizTrain

class NewStringCaseFieldTests: XCTestCase, AddModelTests, CodableTests {

    typealias Object = NewCaseField<NewCaseFieldStringData>

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

    func testCodable() {
        _testCodable()
    }

}

// MARK: - Data

extension NewStringCaseFieldTests {

    struct Properties {

        struct Required {
            static let label = "Label"
            static let name = "quiztrain_name"
            static let includeAll = true
            static let templateIds = [Int]()
            static let isGlobal = true
            static let projectIds = [Int]()
            static let isRequired = false
        }

        struct Optional {
            static let description = "Description"
            static let defaultValue = "Hello QuizTrain!"
        }

    }

}

// MARK: - Objects

extension NewStringCaseFieldTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(description: nil,
                      label: Properties.Required.label,
                      name: Properties.Required.name,
                      includeAll: Properties.Required.includeAll,
                      templateIds: Properties.Required.templateIds,
                      isGlobal: Properties.Required.isGlobal,
                      projectIds: Properties.Required.projectIds,
                      isRequired: Properties.Required.isRequired,
                      defaultValue: nil)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(description: Properties.Optional.description,
                      label: Properties.Required.label,
                      name: Properties.Required.name,
                      includeAll: Properties.Required.includeAll,
                      templateIds: Properties.Required.templateIds,
                      isGlobal: Properties.Required.isGlobal,
                      projectIds: Properties.Required.projectIds,
                      isRequired: Properties.Required.isRequired,
                      defaultValue: Properties.Optional.defaultValue)
    }

}

// MARK: - Assertions

extension NewStringCaseFieldTests: AssertAddRequestJSON { }

extension NewStringCaseFieldTests: AssertCodable { }

extension NewStringCaseFieldTests: AssertEquatable { }

extension NewStringCaseFieldTests: AssertJSONSerializing { }

extension NewStringCaseFieldTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {

        // NewCaseField
        XCTAssertEqual(object.label, Properties.Required.label)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.includeAll, Properties.Required.includeAll)
        XCTAssertEqual(object.templateIds, Properties.Required.templateIds)

        // NewCaseField.Configs
        XCTAssertEqual(object.type, NewCaseFieldType.string)

        // NewCaseField.Configs[0]
        continueAfterFailure = false
        XCTAssertNotNil(object.configs.first)
        continueAfterFailure = true
        let config = object.configs[0]

        // NewCaseField.Configs[0].Context
        XCTAssertEqual(config.context.isGlobal, Properties.Required.isGlobal)
        XCTAssertEqual(config.context.projectIds, Properties.Required.projectIds)

        // NewCaseField.Configs[0].Options
        XCTAssertEqual(config.options.isRequired, Properties.Required.isRequired)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {

        continueAfterFailure = false
        XCTAssertNotNil(object.configs.first)
        continueAfterFailure = true
        let config = object.configs[0]

        if areNil {
            XCTAssertNil(object.description)
            XCTAssertNil(config.options.defaultValue)
        } else {
            XCTAssertEqual(object.description, Properties.Optional.description)
            XCTAssertEqual(config.options.defaultValue, Properties.Optional.defaultValue)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        // Properties

        // NewCaseField
        object.description = "New Description"
        object.label = "New Label"
        object.name = "new_name"
        object.includeAll = false
        object.templateIds = [1, 2, 3]

        // NewCaseField.Configs
        continueAfterFailure = false
        XCTAssertNotNil(object.configs.first)
        continueAfterFailure = true
        var config = object.configs[0]

        // NewCaseField.Configs[0].Context
        config.context.isGlobal = false
        config.context.projectIds = [1, 2, 3]

        // NewCaseField.Configs[0].Options
        config.options.isRequired = true
        config.options.defaultValue = "Goodbye QuizTrain!"

        // Update Context/Options through .data.
        object.data = NewCaseFieldStringData(configs: [config])

        // Assertions

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.label, Properties.Required.label)
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertNotEqual(object.includeAll, Properties.Required.includeAll)
        XCTAssertNotEqual(object.templateIds, Properties.Required.templateIds)
        XCTAssertNotEqual(object.configs[0].context.isGlobal, Properties.Required.isGlobal)
        XCTAssertNotEqual(object.configs[0].context.projectIds, Properties.Required.projectIds)
        XCTAssertNotEqual(object.configs[0].options.defaultValue, Properties.Optional.defaultValue)
        XCTAssertNotEqual(object.configs[0].options.isRequired, Properties.Required.isRequired)

        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.label, "New Label")
        XCTAssertEqual(object.name, "new_name")
        XCTAssertEqual(object.includeAll, false)
        XCTAssertEqual(object.templateIds, [1, 2, 3])
        XCTAssertEqual(object.configs[0].context.isGlobal, false)
        XCTAssertEqual(object.configs[0].context.projectIds, [1, 2, 3])
        XCTAssertEqual(object.configs[0].options.defaultValue, "Goodbye QuizTrain!")
        XCTAssertEqual(object.configs[0].options.isRequired, true)
    }

}
