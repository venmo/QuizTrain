import XCTest

protocol CodableTests {

    func testCodable()
    func _testCodable()

}

extension CodableTests where Self: AssertCodable & ObjectProvider, Self.Object: Codable & Equatable {

    func _testCodable() {
        assertTwoWayJSONCodable(objectWithRequiredProperties)
        assertTwoWayPlistCodable(objectWithRequiredProperties)
        assertTwoWayJSONCodable(objectWithRequiredAndOptionalProperties)
        assertTwoWayPlistCodable(objectWithRequiredAndOptionalProperties)
    }

}
