import XCTest
@testable import QuizTrain

protocol AssertAddRequestJSON {
    func assertAddRequestJSON<Object: AddRequestJSON & AddRequestJSONKeys>(_ object: Object)
}

extension AssertAddRequestJSON {

    func assertAddRequestJSON<Object: AddRequestJSON & AddRequestJSONKeys>(_ object: Object) {
        let addRequestJSON = object.addRequestJSON
        XCTAssertEqual(addRequestJSON.count, object.addRequestJSONKeys.count)
        for key in object.addRequestJSONKeys {
            XCTAssertNotNil(addRequestJSON[key])
        }
    }

}
