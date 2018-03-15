import XCTest

protocol UpdateRequestJSONTests {

    func testUpdateRequestJSON()
    func _testUpdateRequestJSON()

}

extension UpdateRequestJSONTests {

    func _testUpdateRequestJSON() { /* Applies only to tests conforming to AssertUpdateRequestJSON/ObjectProvider. */ }

}

extension UpdateRequestJSONTests where Self: AssertUpdateRequestJSON & ObjectProvider {

    func _testUpdateRequestJSON() {
        let object = objectWithRequiredAndOptionalProperties
        assertUpdateRequestJSON(object)
    }

}
