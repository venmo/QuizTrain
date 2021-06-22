import XCTest
@testable import QuizTrain

protocol InitTests {

    func testInit()
    func testInitWithOptionalProperties()

    func _testInit()
    func _testInitWithOptionalProperties()

}

extension InitTests where Self: AssertProperties & ObjectProvider {

    func _testInit() {
        let object = objectWithRequiredProperties
        assertRequiredProperties(in: object)
        assertOptionalProperties(in: object, areNil: true)
    }

    func _testInitWithOptionalProperties() {
        let object = objectWithRequiredAndOptionalProperties
        assertRequiredProperties(in: object)
        assertOptionalProperties(in: object, areNil: false)
    }

}

extension InitTests where Self: AssertCustomFields & AssertProperties & ObjectProvider, Self.Object: CustomFields {

    func _testInit() {
        let object = objectWithRequiredProperties
        assertRequiredProperties(in: object)
        assertOptionalProperties(in: object, areNil: true)
        assertCustomFields(in: object, areEmpty: true)
    }

    func _testInitWithOptionalProperties() {
        let object = objectWithRequiredAndOptionalProperties
        assertRequiredProperties(in: object)
        assertOptionalProperties(in: object, areNil: false)
        assertCustomFields(in: object, areEmpty: false)
    }

}
