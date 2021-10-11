import XCTest
@testable import QuizTrain

// MARK: - Tests

class ProjectTests: XCTestCase, ModelTests {

    typealias Object = Project

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

extension ProjectTests {

    struct Properties {

        struct Required {
            static let id = 472
            static let isCompleted = true
            static let name = "Name"
            static let showAnnouncement = true
            static let suiteMode = Project.SuiteMode.multipleSuites
            static let url = URL(string: "https://www.testrail.com/")!
        }

        struct Optional {
            static let announcement = "Announcement"
            static let completedOn = Date(secondsSince1970: 72988302)
        }

    }

}

extension ProjectTests: JSONDataProvider {

    static var requiredJSON: JSONDictionary {
        return [Object.JSONKeys.id.rawValue: Properties.Required.id,
                Object.JSONKeys.isCompleted.rawValue: Properties.Required.isCompleted,
                Object.JSONKeys.name.rawValue: Properties.Required.name,
                Object.JSONKeys.showAnnouncement.rawValue: Properties.Required.showAnnouncement,
                Object.JSONKeys.suiteMode.rawValue: Properties.Required.suiteMode.rawValue,
                Object.JSONKeys.url.rawValue: Properties.Required.url.absoluteString]
    }

    static var optionalJSON: JSONDictionary {
        return [Object.JSONKeys.announcement.rawValue: Properties.Optional.announcement,
                Object.JSONKeys.completedOn.rawValue: Properties.Optional.completedOn.secondsSince1970]
    }

}

// MARK: - Objects

extension ProjectTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(announcement: nil,
                      completedOn: nil,
                      id: Properties.Required.id,
                      isCompleted: Properties.Required.isCompleted,
                      name: Properties.Required.name,
                      showAnnouncement: Properties.Required.showAnnouncement,
                      suiteMode: Properties.Required.suiteMode,
                      url: Properties.Required.url)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(announcement: Properties.Optional.announcement,
                      completedOn: Properties.Optional.completedOn,
                      id: Properties.Required.id,
                      isCompleted: Properties.Required.isCompleted,
                      name: Properties.Required.name,
                      showAnnouncement: Properties.Required.showAnnouncement,
                      suiteMode: Properties.Required.suiteMode,
                      url: Properties.Required.url)
    }

}

// MARK: - Assertions

extension ProjectTests: AssertEquatable { }

extension ProjectTests: AssertJSONDeserializing { }

extension ProjectTests: AssertJSONSerializing { }

extension ProjectTests: AssertJSONTwoWaySerialization { }

extension ProjectTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.id, Properties.Required.id)
        XCTAssertEqual(object.isCompleted, Properties.Required.isCompleted)
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.showAnnouncement, Properties.Required.showAnnouncement)
        XCTAssertEqual(object.suiteMode, Properties.Required.suiteMode)
        XCTAssertEqual(object.url, Properties.Required.url)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.announcement)
            XCTAssertNil(object.completedOn)
        } else {
            XCTAssertNotNil(object.announcement)
            XCTAssertNotNil(object.completedOn)
            XCTAssertEqual(object.announcement, Properties.Optional.announcement)
            XCTAssertEqual(object.completedOn, Properties.Optional.completedOn)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.announcement = "New Annoucement"
        object.isCompleted = false
        object.name = "New Name"
        object.showAnnouncement = false
        object.suiteMode = .singleSuitePlusBaselines

        XCTAssertNotEqual(object.announcement, Properties.Optional.announcement)
        XCTAssertNotEqual(object.isCompleted, Properties.Required.isCompleted)
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertNotEqual(object.showAnnouncement, Properties.Required.showAnnouncement)
        XCTAssertNotEqual(object.suiteMode, Properties.Required.suiteMode)

        XCTAssertEqual(object.announcement, "New Annoucement")
        XCTAssertEqual(object.isCompleted, false)
        XCTAssertEqual(object.name, "New Name")
        XCTAssertEqual(object.showAnnouncement, false)
        XCTAssertEqual(object.suiteMode, .singleSuitePlusBaselines)
    }

}

extension ProjectTests: AssertUpdateRequestJSON { }
