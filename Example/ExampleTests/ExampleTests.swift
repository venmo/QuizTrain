import XCTest
@testable import Example

class ExampleTests: XCTestCase {

    func testWhichPasses() {
        XCTContext.runActivity(testing: 10011) { activity in // TODO: Replace this placeholder caseId with one from your project.
            XCTAssertTrue(true, "The value is not true.")
        }
    }

    func testWhichFails() {
        XCTContext.runActivity(testing: 10022) { activity in // TODO: Replace this placeholder caseId with one from your project.
            XCTAssertTrue(false, "The value is not true.")
        }
    }

    func testWithPassingAndFailingAssertions() {

        XCTContext.runActivity(testing: 10033) { activity in // TODO: Replace this placeholder caseId with one from your project.

            XCTAssertTrue(true, "The value is not true.")

            XCTContext.runActivity(testing: [10044, 10055]) { activity in // TODO: Replace these placeholder caseIds with some from your project.
                XCTAssertTrue(false, "The value is not true.")
                XCTAssertFalse(false, "The value is not false.")
            }

            XCTContext.runActivity(testing: [10066, 10077, 10088]) { activity in // TODO: Replace these placeholder with some from your project.
                XCTAssertTrue(true, "The value is not true.")
            }
        }
    }

}
