import XCTest
@testable import QuizTrain

protocol AssertCustomFields {
    func assertCustomFields<Object: CustomFields>(in object: Object, areEmpty: Bool)
}

extension AssertCustomFields {

    func assertCustomFields<Object: CustomFields>(in object: Object, areEmpty: Bool) {
        if areEmpty {
            XCTAssertEqual(object.customFields.count, 0)
        } else {
            XCTAssertGreaterThan(object.customFields.count, 0)
            for (key, _) in object.customFields {
                XCTAssertTrue(key.hasPrefix("custom_"))
            }
        }
    }

}
