import XCTest
@testable import QuizTrain

// MARK: - Tests

class ErrorContainerTests: XCTestCase {

    enum TestError: Error {
        case errorCaseA
        case errorCaseB
        case errorCaseC
    }

    enum TestErrorDebugDescription: String, Error, DebugDescription {

        case errorCaseA
        case errorCaseB
        case errorCaseC

        var debugDescription: String {
            return self.rawValue
        }
    }

    func testSingleError() {

        let error = TestError.errorCaseB
        let container = ErrorContainer(error)

        XCTAssertEqual(container.errors.count, 1)
        XCTAssertTrue(container.errors.contains(error))
    }

    func testMultipleErrors() {

        let errors = [TestError.errorCaseC, TestError.errorCaseB]

        guard let container = ErrorContainer(errors) else {
            XCTFail("ErrorContainer cannot be nil when initialized with 1+ errors: \(errors)")
            return
        }

        XCTAssertEqual(container.errors.count, errors.count)
        for error in errors {
            XCTAssertTrue(container.errors.contains(error))
        }
    }

    func testNoErrors() {

        let errors = [TestError]()
        let container = ErrorContainer(errors)

        XCTAssertNil(container)
    }

    func testDebugDescription() {

        // Simple Errors

        let simpleErrors = [TestError.errorCaseC, TestError.errorCaseB]
        guard let containerA = ErrorContainer(simpleErrors) else {
            XCTFail("Container cannot be nil.")
            return
        }

        XCTAssertGreaterThan(containerA.debugDescription.count, 0)

        // Errors conforming to DebugDescription

        let debugDescriptionErrors = [TestErrorDebugDescription.errorCaseC, TestErrorDebugDescription.errorCaseB]
        guard let containerB = ErrorContainer(debugDescriptionErrors) else {
            XCTFail("Container cannot be nil.")
            return
        }

        XCTAssertGreaterThan(containerB.debugDescription.count, 0)

        for debugDescriptionError in debugDescriptionErrors {
            XCTAssertNotNil(containerB.debugDescription.range(of: debugDescriptionError.rawValue))
        }
    }

}
