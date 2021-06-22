import XCTest
@testable import QuizTrain

class UniqueSelectionTests: XCTestCase {

    func testEquatable() {

        let a: UniqueSelection<Int> = UniqueSelection.all
        let b: UniqueSelection<Int> = UniqueSelection.none
        let c = UniqueSelection.some([1, 2, 3])
        let d = UniqueSelection.some([1, 2, 3, 4])

        XCTAssertEqual(a, UniqueSelection.all)
        XCTAssertEqual(b, UniqueSelection.none)
        XCTAssertEqual(c, UniqueSelection.some([1, 2, 3]))

        XCTAssertNotEqual(a, b)
        XCTAssertNotEqual(a, c)
        XCTAssertNotEqual(a, d)

        XCTAssertNotEqual(b, a)
        XCTAssertNotEqual(b, c)
        XCTAssertNotEqual(b, d)

        XCTAssertNotEqual(c, a)
        XCTAssertNotEqual(c, b)
        XCTAssertNotEqual(c, d)

        XCTAssertNotEqual(d, a)
        XCTAssertNotEqual(d, b)
        XCTAssertNotEqual(d, c)
    }

}
