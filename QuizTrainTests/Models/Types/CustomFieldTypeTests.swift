import XCTest
@testable import QuizTrain

class CustomFieldTypeTests: XCTestCase {

    func testRawValueInit() {
        for i in -1000...0 {
            XCTAssertNil(CustomFieldType(rawValue: i))
        }
        for i in 1...12 {
            XCTAssertNotNil(CustomFieldType(rawValue: i))
        }
        for i in 13...1000 {
            XCTAssertNil(CustomFieldType(rawValue: i))
        }
    }

    func testCaseRawValues() {
        XCTAssertEqual(CustomFieldType.string.rawValue, 1)
        XCTAssertEqual(CustomFieldType.integer.rawValue, 2)
        XCTAssertEqual(CustomFieldType.text.rawValue, 3)
        XCTAssertEqual(CustomFieldType.url.rawValue, 4)
        XCTAssertEqual(CustomFieldType.checkbox.rawValue, 5)
        XCTAssertEqual(CustomFieldType.dropdown.rawValue, 6)
        XCTAssertEqual(CustomFieldType.user.rawValue, 7)
        XCTAssertEqual(CustomFieldType.date.rawValue, 8)
        XCTAssertEqual(CustomFieldType.milestone.rawValue, 9)
        XCTAssertEqual(CustomFieldType.steps.rawValue, 10)
        XCTAssertEqual(CustomFieldType.stepResults.rawValue, 11)
        XCTAssertEqual(CustomFieldType.multiSelect.rawValue, 12)
    }

    func testDescription() {
        XCTAssertEqual(CustomFieldType.string.description(), "String")
        XCTAssertEqual(CustomFieldType.integer.description(), "Integer")
        XCTAssertEqual(CustomFieldType.text.description(), "Text")
        XCTAssertEqual(CustomFieldType.url.description(), "URL")
        XCTAssertEqual(CustomFieldType.checkbox.description(), "Checkbox")
        XCTAssertEqual(CustomFieldType.dropdown.description(), "Dropdown")
        XCTAssertEqual(CustomFieldType.user.description(), "User")
        XCTAssertEqual(CustomFieldType.date.description(), "Date")
        XCTAssertEqual(CustomFieldType.milestone.description(), "Milestone")
        XCTAssertEqual(CustomFieldType.steps.description(), "Steps")
        XCTAssertEqual(CustomFieldType.stepResults.description(), "Step Results")
        XCTAssertEqual(CustomFieldType.multiSelect.description(), "Multi-Select")
    }

}
