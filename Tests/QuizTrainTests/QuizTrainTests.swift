import XCTest
@testable import QuizTrain

final class QuizTrainTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(QuizTrain().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
