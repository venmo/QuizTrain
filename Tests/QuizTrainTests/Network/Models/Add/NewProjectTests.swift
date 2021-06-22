import XCTest
@testable import QuizTrain

// MARK: - Tests

class NewProjectTests: XCTestCase, AddModelTests {

    typealias Object = NewProject

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

extension NewProjectTests {

    struct Properties {

        struct Required {
            static let name = "Name"
            static let showAnnouncement = true
            static let suiteMode = Project.SuiteMode.multipleSuites
        }

        struct Optional {
            static let announcement = "Announcement"
        }

    }

}

// MARK: - Objects

extension NewProjectTests: ObjectProvider {

    static var objectWithRequiredProperties: Object {
        return Object(announcement: nil,
                      name: Properties.Required.name,
                      showAnnouncement: Properties.Required.showAnnouncement,
                      suiteMode: Properties.Required.suiteMode)
    }

    static var objectWithRequiredAndOptionalProperties: Object {
        return Object(announcement: Properties.Optional.announcement,
                      name: Properties.Required.name,
                      showAnnouncement: Properties.Required.showAnnouncement,
                      suiteMode: Properties.Required.suiteMode)
    }

}

// MARK: - Assertions

extension NewProjectTests: AssertAddRequestJSON { }

extension NewProjectTests: AssertEquatable { }

extension NewProjectTests: AssertJSONSerializing { }

extension NewProjectTests: AssertProperties {

    func assertRequiredProperties(in object: Object) {
        XCTAssertEqual(object.name, Properties.Required.name)
        XCTAssertEqual(object.showAnnouncement, Properties.Required.showAnnouncement)
        XCTAssertEqual(object.suiteMode, Properties.Required.suiteMode)
    }

    func assertOptionalProperties(in object: Object, areNil: Bool) {
        if areNil {
            XCTAssertNil(object.announcement)
        } else {
            XCTAssertNotNil(object.announcement)
            XCTAssertEqual(object.announcement, Properties.Optional.announcement)
        }
    }

    func assertVariablePropertiesCanBeChanged(in object: inout Object) {

        object.announcement = "New Announcement"
        object.name = "New Name"
        object.showAnnouncement = false
        object.suiteMode = .singleSuite

        XCTAssertNotEqual(object.announcement, Properties.Optional.announcement)
        XCTAssertNotEqual(object.name, Properties.Required.name)
        XCTAssertNotEqual(object.showAnnouncement, Properties.Required.showAnnouncement)
        XCTAssertNotEqual(object.suiteMode, Properties.Required.suiteMode)

        XCTAssertEqual(object.announcement, "New Announcement")
        XCTAssertEqual(object.name, "New Name")
        XCTAssertEqual(object.showAnnouncement, false)
        XCTAssertEqual(object.suiteMode, .singleSuite)
    }

}
