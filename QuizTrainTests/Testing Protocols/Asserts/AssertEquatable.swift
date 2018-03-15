import XCTest

protocol AssertEquatable {
    func assertEqual<Object: Equatable>(_ lhs: Object?, _ rhs: Object?)
    func assertNotEqual<Object: Equatable>(_ lhs: Object?, _ rhs: Object?)
}

extension AssertEquatable {

    func assertEqual<Object: Equatable>(_ lhs: Object?, _ rhs: Object?) {
        XCTAssertEqual(lhs, rhs)
    }

    func assertNotEqual<Object: Equatable>(_ lhs: Object?, _ rhs: Object?) {
        XCTAssertNotEqual(lhs, rhs)
    }

}
