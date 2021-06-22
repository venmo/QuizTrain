import XCTest

protocol EquatableTests {

    func testEquatable()
    func _testEquatable()

}

extension EquatableTests where Self: AssertEquatable & ObjectProvider, Self.Object: Equatable {

    func _testEquatable() {
        let objectA = objectWithRequiredAndOptionalProperties
        let objectB = objectWithRequiredAndOptionalProperties
        assertEqual(objectA, objectB)
        assertNotEqual(objectA, nil)
    }

}
