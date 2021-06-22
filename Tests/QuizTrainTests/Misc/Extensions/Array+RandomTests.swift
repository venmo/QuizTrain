import XCTest
@testable import QuizTrain

// MARK: - Tests

class Array_RandomTests: XCTestCase {

    func testRandomIndex() {

        let arrayA = [Int]()
        XCTAssertNil(arrayA.randomIndex)

        let arrayB = [1]
        XCTAssertEqual(arrayB.randomIndex, 0)

        let arrayC = [1, 2, 3]
        let randomIndex = arrayC.randomIndex
        XCTAssertNotNil(randomIndex)
        if let randomIndex = randomIndex {
            XCTAssertLessThan(randomIndex, arrayC.count)
        }
    }

    func testRandomElement() {

        let arrayA = [Int]()
        XCTAssertNil(arrayA.randomElement)

        let arrayB = [1]
        XCTAssertEqual(arrayB.randomElement, 1)

        let arrayC = [1, 2, 3]
        let randomElement = arrayC.randomElement
        XCTAssertNotNil(randomElement)
        if let randomElement = randomElement {
            XCTAssertTrue(arrayC.contains(randomElement))
        }
    }

}
