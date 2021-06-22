import XCTest
@testable import QuizTrain

protocol AssertCodable {
    func assertTwoWayJSONCodable<Object: Codable & Equatable>(_ object: Object)
    func assertTwoWayPlistCodable<Object: Codable & Equatable>(_ object: Object)
}

extension AssertCodable {

    func assertTwoWayJSONCodable<Object: Codable & Equatable>(_ object: Object) {

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        // Object -> JSON

        let data: Data
        do {
            data = try encoder.encode(object)
        } catch {
            XCTFail("Encoding \(object) failed with error: \(error)")
            return
        }

        // JSON -> Object

        let decodedObject: Object
        do {
            decodedObject = try decoder.decode(Object.self, from: data)
        } catch {
            XCTFail("Decoding \(object) failed with error: \(error)")
            return
        }

        XCTAssertEqual(object, decodedObject)
    }

    func assertTwoWayPlistCodable<Object: Codable & Equatable>(_ object: Object) {

        let encoder = PropertyListEncoder()
        let decoder = PropertyListDecoder()

        // Object -> .plist

        let data: Data
        do {
            data = try encoder.encode(object)
        } catch {
            XCTFail("Encoding \(object) failed with error: \(error)")
            return
        }

        // .plist -> Object

        let decodedObject: Object
        do {
            decodedObject = try decoder.decode(Object.self, from: data)
        } catch {
            XCTFail("Decoding \(object) failed with error: \(error)")
            return
        }

        XCTAssertEqual(object, decodedObject)
    }

}
