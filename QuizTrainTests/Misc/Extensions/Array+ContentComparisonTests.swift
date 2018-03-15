import XCTest
@testable import QuizTrain

// MARK: - Tests

class Array_ContentComparisonTests: XCTestCase {

    func testContentsOfArrayAreEqualToArray() {

        let arrayA = [1, 2, 3]

        XCTAssertTrue(arrayA.contentsAreEqual(to: arrayA))

        let arrayB = [1, 2, 3]

        XCTAssertTrue(arrayA.contentsAreEqual(to: arrayB))

        let arrayC = [3, 2, 1]

        XCTAssertNotEqual(arrayA, arrayC)
        XCTAssertTrue(arrayA.contentsAreEqual(to: arrayC))

        let arrayD = [1, 2]

        XCTAssertFalse(arrayA.contentsAreEqual(to: arrayD))

        let arrayE = [1, 2, 3, 4]

        XCTAssertFalse(arrayA.contentsAreEqual(to: arrayE))

        let arrayF: [Int]? = nil

        XCTAssertFalse(arrayA.contentsAreEqual(to: arrayF))
        XCTAssertTrue(Array.contentsAreEqual(arrayF, arrayF))

        let arrayG = [1, 1, 2]
        let arrayH = [1, 2, 2]

        XCTAssertFalse(arrayG.contentsAreEqual(to: arrayH))
    }

}
