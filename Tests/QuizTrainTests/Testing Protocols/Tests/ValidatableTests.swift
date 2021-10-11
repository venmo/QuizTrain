import XCTest

protocol ValidatableTests {

    func testIsValid()
    func testIsInvalid()
    func _testIsValid()
    func _testIsInvalid()

}

extension ValidatableTests where Self: AssertValidatable & ValidatableObjectProvider {

    func _testIsValid() {
        assertValid(validObject)
    }

    func _testIsInvalid() {
        assertInvalid(invalidObject)
    }

}
