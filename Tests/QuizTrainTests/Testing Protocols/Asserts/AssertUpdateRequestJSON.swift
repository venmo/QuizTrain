import XCTest
@testable import QuizTrain

protocol AssertUpdateRequestJSON {
    associatedtype Object: UpdateRequestJSON, UpdateRequestJSONKeys
    func assertUpdateRequestJSON(_ object: Object)
}

extension AssertUpdateRequestJSON {

    func assertUpdateRequestJSON(_ object: Object) {
        let updateRequestJSON = object.updateRequestJSON
        XCTAssertEqual(updateRequestJSON.count, object.updateRequestJSONKeys.count)
        for key in object.updateRequestJSONKeys {
            XCTAssertNotNil(updateRequestJSON[key])
        }
    }

}
