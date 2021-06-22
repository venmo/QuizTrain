import XCTest
@testable import QuizTrain

protocol JSONDeserializingTests {

    func testJSONDeserializing()
    func testJSONDeserializingWithOptionalProperties()
    func testJSONDeserializingASingleObject()
    func testJSONDeserializingMultipleObjects()
    func testJSONDeserializingASingleObjectMissingRequiredProperties()
    func testJSONDeserializingMultipleObjectsMissingRequiredProperties()

    func _testJSONDeserializing()
    func _testJSONDeserializingWithOptionalProperties()
    func _testJSONDeserializingASingleObject()
    func _testJSONDeserializingMultipleObjects()
    func _testJSONDeserializingASingleObjectMissingRequiredProperties()
    func _testJSONDeserializingMultipleObjectsMissingRequiredProperties()

}

extension JSONDeserializingTests where Self: AssertJSONDeserializing & AssertProperties & JSONDataProvider & ObjectProvider, Self.Object: JSONDeserializable {

    func _testJSONDeserializing() {
        guard let object = objectWithRequiredPropertiesFromJSON else {
            XCTFail("nil object returned.")
            return
        }
        assertRequiredProperties(in: object)
        assertOptionalProperties(in: object, areNil: true)
    }

    func _testJSONDeserializingWithOptionalProperties() {
        guard let object = objectWithRequiredAndOptionalPropertiesFromJSON else {
            XCTFail("nil object returned.")
            return
        }
        assertRequiredProperties(in: object)
        assertOptionalProperties(in: object, areNil: false)
    }

    func _testJSONDeserializingASingleObject() {
        assertJSONDeserializing(type: Object.self, from: requiredAndOptionalJSON)
    }

    func _testJSONDeserializingMultipleObjects() {
        assertJSONDeserializing(type: Object.self, from: [requiredAndOptionalJSON, requiredAndOptionalJSON, requiredAndOptionalJSON])
    }

    func _testJSONDeserializingASingleObjectMissingRequiredProperties() {
        assertJSONDeserializing(type: Object.self, failsByOmittingKeysFrom: requiredJSON)
    }

    func _testJSONDeserializingMultipleObjectsMissingRequiredProperties() {
        assertJSONDeserializing(type: Object.self, failsByOmittingKeysFrom: [requiredJSON, requiredJSON, requiredJSON])
    }

}

extension JSONDeserializingTests where Self: AssertCustomFields & AssertJSONDeserializing & AssertProperties & JSONDataProvider & ObjectProvider, Self.Object: CustomFields & JSONDeserializable {

    func _testJSONDeserializing() {
        guard let object = objectWithRequiredPropertiesFromJSON else {
            XCTFail("nil object returned.")
            return
        }
        assertRequiredProperties(in: object)
        assertOptionalProperties(in: object, areNil: true)
        assertCustomFields(in: object, areEmpty: true)
    }

    func _testJSONDeserializingWithOptionalProperties() {
        guard let object = objectWithRequiredAndOptionalPropertiesFromJSON else {
            XCTFail("nil object returned.")
            return
        }
        assertRequiredProperties(in: object)
        assertOptionalProperties(in: object, areNil: false)
        assertCustomFields(in: object, areEmpty: false)
    }

}
