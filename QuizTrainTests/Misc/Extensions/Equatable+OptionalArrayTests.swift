import XCTest
@testable import QuizTrain

// MARK: - Tests

class Equatable_OptionalArrayTests: XCTestCase {

    func testEquatableWithOptionalArrays() {

        let arrayA = [1, 2, 3]
        let arrayB = [1, 2, 3]
        let arrayC = [4, 5, 6]
        let arrayD: [Int]? = nil
        let arrayE: [Int]? = nil
        let arrayF: [Int]? = [1, 2, 3]

        XCTAssertTrue(arrayA == arrayA)
        XCTAssertTrue(arrayA == arrayB)
        XCTAssertFalse(arrayA == arrayC)
        XCTAssertFalse(arrayA == arrayD)
        XCTAssertTrue(arrayD == arrayE)
        XCTAssertTrue(arrayA == arrayF)
    }

}
