import XCTest
@testable import QuizTrain

class Project_SuiteModeTests: XCTestCase {

    func testRawValueInit() {
        for i in -1000...0 {
            XCTAssertNil(Project.SuiteMode(rawValue: i))
        }
        for i in 1...3 {
            XCTAssertNotNil(Project.SuiteMode(rawValue: i))
        }
        for i in 4...1000 {
            XCTAssertNil(Project.SuiteMode(rawValue: i))
        }
    }

    func testCaseRawValues() {
        XCTAssertEqual(Project.SuiteMode.singleSuite.rawValue, 1)
        XCTAssertEqual(Project.SuiteMode.singleSuitePlusBaselines.rawValue, 2)
        XCTAssertEqual(Project.SuiteMode.multipleSuites.rawValue, 3)
    }

    func testDescription() {
        XCTAssertEqual(Project.SuiteMode.singleSuite.description(), "Single Suite")
        XCTAssertEqual(Project.SuiteMode.singleSuitePlusBaselines.description(), "Single Suite Plus Baselines")
        XCTAssertEqual(Project.SuiteMode.multipleSuites.description(), "Multiple Suites")
    }

}
