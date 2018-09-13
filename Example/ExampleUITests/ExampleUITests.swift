import XCTest

class ExampleUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        app.launch()
    }

    func testWhichPasses() {
        #error("Replace the placeholder caseId below with one from your project. Then comment out this macro.")
        XCTContext.runActivity(testing: 20011) { activity in
            let query = app.staticTexts["exampleLabel"]
            XCTAssertTrue(query.exists, query.debugDescription)
        }
    }

    func testWhichFails() {
        #error("Replace the placeholder caseId below with one from your project. Then comment out this macro.")
        XCTContext.runActivity(testing: 20022) { activity in
            let query = app.staticTexts["non-existant accessibility identifier"]
            XCTAssertTrue(query.exists, query.debugDescription)
        }
    }

    func testWithPassingAndFailingAssertions() {

        #error("Replace the placeholder caseId below with one from your project. Then comment out this macro.")
        XCTContext.runActivity(testing: 20033) { activity in

            let queryA = app.staticTexts["exampleLabel"]
            XCTAssertTrue(queryA.exists, queryA.debugDescription)

            #error("Replace the placeholder caseIds below with ones from your project. Then comment out this macro.")
            XCTContext.runActivity(testing: [20044, 20055]) { activity in
                let queryB = app.staticTexts["non-existant accessibility identifier"]
                XCTAssertTrue(queryB.exists, queryB.debugDescription)
                XCTAssertFalse(queryB.exists, queryB.debugDescription)
            }

            #error("Replace the placeholder caseIds below with ones from your project. Then comment out this macro.")
            XCTContext.runActivity(testing: [20066, 20077, 20088]) { activity in
                let queryC = app.staticTexts["exampleLabel"]
                XCTAssertEqual(queryC.label, "QuizTrain Example", queryC.debugDescription)
            }
        }
    }

}
