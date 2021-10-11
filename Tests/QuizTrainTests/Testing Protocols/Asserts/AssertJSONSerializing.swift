import XCTest
@testable import QuizTrain

protocol AssertJSONSerializing {
    func assertJSONSerializing<Object: JSONSerializable>(_ object: Object)
    func assertJSONSerializing<Object: JSONSerializable>(_ objects: [Object])
}

extension AssertJSONSerializing {

    func assertJSONSerializing<Object: JSONSerializable>(_ object: Object) {
        let serializedA: JSONDictionary = Object.serialized(object)
        XCTAssertNotNil(serializedA) // This will always pass.
        let serializedB = object.serialized()
        XCTAssertNotNil(serializedB) // This will always pass.
    }

    func assertJSONSerializing<Object: JSONSerializable>(_ objects: [Object]) {
        let serialized: [JSONDictionary] = Object.serialized(objects)
        XCTAssertNotNil(serialized) // This will always pass.
        XCTAssertEqual(serialized.count, objects.count)
    }

}
