import XCTest
@testable import QuizTrain

class NewTextCaseFieldTests: XCTestCase, AddModelTests, CodableTests {

    typealias Object = NewCaseField<NewCaseFieldTextData>

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

extension NewTextCaseFieldTests {

    struct Properties {

        struct Required {
            static let label = "Label"
            static let name = "quiztrain_name"
            static let includeAll = true
            static let templateIds = [Int]()
            static let isGlobal = true
            static let projectIds = [Int]()
            static let isRequired = false
            static let format = NewCaseFieldConfigTextOptions.Format.plain
            static let rows = NewCaseFieldConfigTextOptions.Rows.five
        }

        struct Optional {
            static let description = "Description"
            static let defaultValue = "Hello QuizTrain!"
        }

    }

}

// MARK: - Objects

extension NewTextCaseFieldTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(description: nil,
                      label: Properties.Required.label,
                      name: Properties.Required.name,
                      includeAll: Properties.Required.includeAll,
                      templateIds: Properties.Required.templateIds,
                      isGlobal: Properties.Required.isGlobal,
                      projectIds: Properties.Required.projectIds,
                      isRequired: Properties.Required.isRequired,
                      defaultValue: nil,
                      format: Properties.Required.format,
                      rows: Properties.Required.rows)
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
                      defaultValue: Properties.Optional.defaultValue,
                      format: Properties.Required.format,
                      rows: Properties.Required.rows)
    }

}

// MARK: - Assertions

extension NewTextCaseFieldTests: AssertAddRequestJSON { }

extension NewTextCaseFieldTests: AssertCodable { }

extension NewTextCaseFieldTests: AssertEquatable { }

extension NewTextCaseFieldTests: AssertJSONSerializing { }

extension NewTextCaseFieldTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {

        // NewCaseField
        XCTAssertEqual(object.label, Properties.Required.label)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.includeAll, Properties.Required.includeAll)
        XCTAssertEqual(object.templateIds, Properties.Required.templateIds)

        // NewCaseField.Configs
        XCTAssertEqual(object.type, NewCaseFieldType.text)

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
        XCTAssertEqual(config.options.format, Properties.Required.format)
        XCTAssertEqual(config.options.rows, Properties.Required.rows)
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
        config.options.format = .markdown
        config.options.rows = .unspecified

        // Update Context/Options through .data.
        object.data = NewCaseFieldTextData(configs: [config])

        // Assertions

        XCTAssertNotEqual(object.description, Properties.Optional.description)
        XCTAssertNotEqual(object.label, Properties.Required.label)
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertNotEqual(object.includeAll, Properties.Required.includeAll)
        XCTAssertNotEqual(object.templateIds, Properties.Required.templateIds)
        XCTAssertNotEqual(object.configs[0].context.isGlobal, Properties.Required.isGlobal)
        XCTAssertNotEqual(object.configs[0].context.projectIds, Properties.Required.projectIds)
        XCTAssertNotEqual(object.configs[0].options.isRequired, Properties.Required.isRequired)
        XCTAssertNotEqual(object.configs[0].options.defaultValue, Properties.Optional.defaultValue)
        XCTAssertNotEqual(object.configs[0].options.format, Properties.Required.format)
        XCTAssertNotEqual(object.configs[0].options.rows, Properties.Required.rows)

        XCTAssertEqual(object.description, "New Description")
        XCTAssertEqual(object.label, "New Label")
        XCTAssertEqual(object.name, "new_name")
        XCTAssertEqual(object.includeAll, false)
        XCTAssertEqual(object.templateIds, [1, 2, 3])
        XCTAssertEqual(object.configs[0].context.isGlobal, false)
        XCTAssertEqual(object.configs[0].context.projectIds, [1, 2, 3])
        XCTAssertEqual(object.configs[0].options.isRequired, true)
        XCTAssertEqual(object.configs[0].options.defaultValue, "Goodbye QuizTrain!")
        XCTAssertEqual(object.configs[0].options.format, .markdown)
        XCTAssertEqual(object.configs[0].options.rows, .unspecified)
    }

}
