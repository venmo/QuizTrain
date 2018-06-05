import XCTest
@testable import QuizTrain

// MARK: - Tests

class ErrorContainerTests: XCTestCase {

    enum TestError: Error {
        case errorCaseA
        case errorCaseB
        case errorCaseC
    }

    enum TestErrorCustomDebugStringConvertible: String, Error, CustomDebugStringConvertible {

        case errorCaseA
        case errorCaseB
        case errorCaseC

        public var debugDescription: String {
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

    func testCustomDebugStringConvertible() {

        // Simple Errors

        let simpleErrors = [TestError.errorCaseC, TestError.errorCaseB]
        guard let containerA = ErrorContainer(simpleErrors) else {
            XCTFail("Container cannot be nil.")
            return
        }

        XCTAssertGreaterThan(containerA.debugDescription.count, 0)

        // Errors conforming to CustomDebugStringConvertible

        let customDebugStringConvertibleErrors = [TestErrorCustomDebugStringConvertible.errorCaseC, TestErrorCustomDebugStringConvertible.errorCaseB]
        guard let containerB = ErrorContainer(customDebugStringConvertibleErrors) else {
            XCTFail("Container cannot be nil.")
            return
        }

        XCTAssertGreaterThan(containerB.debugDescription.count, 0)

        for debugDescriptionError in customDebugStringConvertibleErrors {
            XCTAssertNotNil(containerB.debugDescription.range(of: debugDescriptionError.rawValue))
        }
    }

}
