import XCTest
@testable import QuizTrain

protocol JSONSerializingTests {

    func testJSONSerializingSingleObjects()
    func testJSONSerializingMultipleObjects()

    func _testJSONSerializingSingleObjects()
    func _testJSONSerializingMultipleObjects()

}

extension JSONSerializingTests where Self: AssertJSONSerializing & ObjectProvider, Self.Object: JSONSerializable {

    func _testJSONSerializingSingleObjects() {
        assertJSONSerializing(objectWithRequiredProperties)
        assertJSONSerializing(objectWithRequiredAndOptionalProperties)
    }

    func _testJSONSerializingMultipleObjects() {
        assertJSONSerializing([objectWithRequiredProperties, objectWithRequiredProperties, objectWithRequiredProperties])
        assertJSONSerializing([objectWithRequiredAndOptionalProperties, objectWithRequiredAndOptionalProperties, objectWithRequiredAndOptionalProperties])
    }

}
