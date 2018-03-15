import XCTest
@testable import QuizTrain

// MARK: - Tests

class AsyncOperationTests: XCTestCase {

    func testIsAsynchronous() {
        let operation = AsyncOperation()
        XCTAssertTrue(operation.isAsynchronous)
    }

    func testState() {

        let operation = AsyncOperation()

        XCTAssertTrue(operation.isReady)

        operation.state = .executing
        XCTAssertTrue(operation.isExecuting)

        operation.state = .finished
        XCTAssertTrue(operation.isFinished)
    }

}
