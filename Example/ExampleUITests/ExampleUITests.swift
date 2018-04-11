import XCTest

class ExampleUITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        app.launch()
    }

    func testWhichPasses() {
        XCTContext.runActivity(testing: 20011) { activity in // TODO: Replace this placeholder caseId with one from your project.
            let query = app.staticTexts["exampleLabel"]
            XCTAssertTrue(query.exists, query.debugDescription)
        }
    }

    func testWhichFails() {
        XCTContext.runActivity(testing: 20022) { activity in // TODO: Replace this placeholder caseId with one from your project.
            let query = app.staticTexts["non-existant accessibility identifier"]
            XCTAssertTrue(query.exists, query.debugDescription)
        }
    }

    func testWithPassingAndFailingAssertions() {

        XCTContext.runActivity(testing: 20033) { activity in // TODO: Replace this placeholder caseId with one from your project.

            let queryA = app.staticTexts["exampleLabel"]
            XCTAssertTrue(queryA.exists, queryA.debugDescription)

            XCTContext.runActivity(testing: [20044, 20055]) { activity in // TODO: Replace these placeholder caseIds with some from your project.
                let queryB = app.staticTexts["non-existant accessibility identifier"]
                XCTAssertTrue(queryB.exists, queryB.debugDescription)
                XCTAssertFalse(queryB.exists, queryB.debugDescription)
            }

            XCTContext.runActivity(testing: [20066, 20077, 20088]) { activity in // TODO: Replace these placeholder with some from your project.
                let queryC = app.staticTexts["exampleLabel"]
                XCTAssertEqual(queryC.label, "QuizTrain Example", queryC.debugDescription)
            }
        }
    }

}
