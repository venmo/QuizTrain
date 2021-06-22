import XCTest

protocol JSONTwoWaySerializationTests {

    func testJSONTwoWaySerializationForSingleItems()
    func testJSONTwoWaySerializationForMultipleItems()

    func _testJSONTwoWaySerializationForSingleItems()
    func _testJSONTwoWaySerializationForMultipleItems()

}

extension JSONTwoWaySerializationTests where Self: AssertJSONTwoWaySerialization & JSONDataProvider & ObjectProvider {

    func _testJSONTwoWaySerializationForSingleItems() {
        // Object -> JSON -> Object
        assertJSONTwoWaySerialization(objectWithRequiredProperties)
        assertJSONTwoWaySerialization(objectWithRequiredAndOptionalProperties)
        // JSON -> Object -> JSON
        assertJSONTwoWaySerialization(requiredJSON)
        assertJSONTwoWaySerialization(requiredAndOptionalJSON)
    }

    func _testJSONTwoWaySerializationForMultipleItems() {
        // Object -> JSON -> Object
        assertJSONTwoWaySerialization([objectWithRequiredProperties, objectWithRequiredProperties, objectWithRequiredProperties])
        assertJSONTwoWaySerialization([objectWithRequiredAndOptionalProperties, objectWithRequiredAndOptionalProperties, objectWithRequiredAndOptionalProperties])
        // JSON -> Object -> JSON
        assertJSONTwoWaySerialization([requiredJSON, requiredJSON, requiredJSON])
        assertJSONTwoWaySerialization([requiredAndOptionalJSON, requiredAndOptionalJSON, requiredAndOptionalJSON])
    }

}
