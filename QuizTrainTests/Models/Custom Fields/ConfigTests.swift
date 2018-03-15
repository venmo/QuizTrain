import XCTest
@testable import QuizTrain

// MARK: - Tests

class ConfigTests: XCTestCase, ModelTests {

    typealias Object = Config

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

    func testProjects() {

        let contextA = Object.Context(isGlobal: true, projectIds: nil)
        let objectA = Object(context: contextA, id: "id", optionsContainer: Config.OptionsContainer(json: ["test": "test"]))
        assertProjects(in: objectA)

        let contextB = Object.Context(isGlobal: false, projectIds: nil)
        let objectB = Object(context: contextB, id: "id", optionsContainer: Config.OptionsContainer(json: ["test": "test"]))
        assertProjects(in: objectB)

        let contextC = Object.Context(isGlobal: false, projectIds: [1, 2, 3])
        let objectC = Object(context: contextC, id: "id", optionsContainer: Config.OptionsContainer(json: ["test": "test"]))
        assertProjects(in: objectC)
    }

}

// MARK: - Data

extension ConfigTests {

    struct Properties {

        struct Required {
            static let context = Config_ContextTests.objectWithRequiredAndOptionalPropertiesFromJSON! // This must match the order and datasources in: JSON.required["context"]
            static let id = "id"
            static let options: [String: Any] = ["optionA": true, "optionB": "Hello", "optionC": [1, 2.0, -3]]
        }

        struct Optional {
            // none
        }

    }

}

extension ConfigTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.context.rawValue: Config_ContextTests.requiredAndOptionalJSON, // This must match the order and datasources in: Properties.Required.context
                Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.options.rawValue: Properties.Required.options]
    }

    static var optionalJSON: JSONDictionary {
        return [:] // none
    }

}

// MARK: - Objects

extension ConfigTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(context: Properties.Required.context,
                      id: Properties.Required.id,
                      optionsContainer: Config.OptionsContainer(json: Properties.Required.options))
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(context: Properties.Required.context,
                      id: Properties.Required.id,
                      optionsContainer: Config.OptionsContainer(json: Properties.Required.options))
    }

}

// MARK: - Assertions

extension ConfigTests {

    func assertProjects(in object: Object) {
        if object.context.isGlobal {
            XCTAssertEqual(object.projects, UniqueSelection.all)
        } else if object.context.projectIds == nil {
            XCTAssertEqual(object.projects, UniqueSelection.none)
        } else {
            XCTAssertNotNil(object.context.projectIds)
            if let projectIds = object.context.projectIds {
                XCTAssertEqual(object.projects, UniqueSelection.some(Set(projectIds)))
            }
        }
    }

}

extension ConfigTests: AssertEquatable { }

extension ConfigTests: AssertJSONDeserializing { }

extension ConfigTests: AssertJSONSerializing { }

extension ConfigTests: AssertJSONTwoWaySerialization { }

extension ConfigTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertNotNil(object.context)
        XCTAssertEqual(object.context.isGlobal, Properties.Required.context.isGlobal)
        XCTAssertNotNil(object.context.projectIds)
        XCTAssertNotNil(Properties.Required.context.projectIds)
        XCTAssertEqual(object.context.projectIds!, Properties.Required.context.projectIds!)
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.options.count, Properties.Required.options.count)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) { /* none */ }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) { /* none */ }

}
