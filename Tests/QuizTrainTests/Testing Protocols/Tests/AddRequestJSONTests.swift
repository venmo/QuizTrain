import XCTest
@testable import QuizTrain

protocol AddRequestJSONTests {

    func testAddRequestJSON()
    func _testAddRequestJSON()

}

extension AddRequestJSONTests where Self: AssertAddRequestJSON & ObjectProvider, Self.Object: AddRequestJSON & AddRequestJSONKeys {

    func _testAddRequestJSON() {
        let object = objectWithRequiredAndOptionalProperties
        assertAddRequestJSON(object)
    }

}
