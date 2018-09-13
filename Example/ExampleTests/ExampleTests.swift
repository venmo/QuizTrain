import XCTest
@testable import Example

class ExampleTests: XCTestCase {

    func testWhichPasses() {
        #error("Replace the placeholder caseId below with one from your project. Then comment out this macro.")
        XCTContext.runActivity(testing: 10011) { activity in
            XCTAssertTrue(true, "The value is not true.")
        }
    }

    func testWhichFails() {
        #error("Replace the placeholder caseId below with one from your project. Then comment out this macro.")
        XCTContext.runActivity(testing: 10022) { activity in
            XCTAssertTrue(false, "The value is not true.")
        }
    }

    func testWithPassingAndFailingAssertions() {

        #error("Replace the placeholder caseId below with one from your project. Then comment out this macro.")
        XCTContext.runActivity(testing: 10033) { activity in

            XCTAssertTrue(true, "The value is not true.")

            #error("Replace the placeholder caseIds below with ones from your project. Then comment out this macro.")
            XCTContext.runActivity(testing: [10044, 10055]) { activity in
                XCTAssertTrue(false, "The value is not true.")
                XCTAssertFalse(false, "The value is not false.")
            }

            #error("Replace the placeholder caseIds below with ones from your project. Then comment out this macro.")
            XCTContext.runActivity(testing: [10066, 10077, 10088]) { activity in
                XCTAssertTrue(true, "The value is not true.")
            }
        }
    }

}
