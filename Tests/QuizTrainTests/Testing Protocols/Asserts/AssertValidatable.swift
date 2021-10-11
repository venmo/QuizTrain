import XCTest
@testable import QuizTrain

protocol AssertValidatable {
    func assertValid(_ object: Validatable)
    func assertInvalid(_ object: Validatable)
}

extension AssertValidatable {

    func assertValid(_ object: Validatable) {
        XCTAssertTrue(object.isValid)
    }

    func assertInvalid(_ object: Validatable) {
        XCTAssertFalse(object.isValid)
    }

}
