import XCTest
@testable import QuizTrain

protocol ValidatableObjectProvider {
    var validObject: Validatable { get }
    var invalidObject: Validatable { get }
}
