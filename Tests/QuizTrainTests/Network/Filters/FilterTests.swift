import XCTest
@testable import QuizTrain

// MARK: - Tests

class FilterTests: XCTestCase {

    func testInitWithBool() {
        let filter = Filter(named: "Bool", matching: true)
        XCTAssertEqual(filter.name, "Bool")
        XCTAssertEqual(filter.value, .bool(true))
    }

    func testInitWithDate() {
        let date = Date()
        let filter = Filter(named: "Date", matching: date)
        XCTAssertEqual(filter.name, "Date")
        XCTAssertEqual(filter.value, .timestamp(date))
    }

    func testInitWithInt() {
        let filter = Filter(named: "Int", matching: 100)
        XCTAssertEqual(filter.name, "Int")
        XCTAssertEqual(filter.value, .int(100))
    }

    func testInitWithIntList() {
        let filter = Filter(named: "IntList", matching: [1, 2, 3])
        XCTAssertEqual(filter.name, "IntList")
        XCTAssertEqual(filter.value, .intList([1, 2, 3]))
    }

    func testEquatable() {

        let objectA = Filter(named: "Hello", matching: true)
        let objectB = Filter(named: "Hello", matching: 1)
        let objectC = Filter(named: "Hello", matching: [100, 200, 300])
        let objectD = Filter(named: "Hello", matching: Date())

        XCTAssertNotEqual(objectA, objectB)
        XCTAssertNotEqual(objectA, objectC)
        XCTAssertNotEqual(objectA, objectD)

        XCTAssertNotEqual(objectB, objectA)
        XCTAssertNotEqual(objectB, objectC)
        XCTAssertNotEqual(objectB, objectD)

        XCTAssertNotEqual(objectC, objectA)
        XCTAssertNotEqual(objectC, objectB)
        XCTAssertNotEqual(objectC, objectD)

        XCTAssertNotEqual(objectD, objectA)
        XCTAssertNotEqual(objectD, objectB)
        XCTAssertNotEqual(objectD, objectC)
    }

    func testEquatableBool() {

        let objectA = Filter(named: "Hello", matching: true)
        var objectB = Filter(named: "Hello", matching: true)
        let objectC = Filter(named: "Hello", matching: false)

        XCTAssertEqual(objectA, objectA)
        XCTAssertEqual(objectA, objectB)
        XCTAssertNotEqual(objectA, objectC)

        objectB.value = .bool(false)

        XCTAssertNotEqual(objectA, objectB)
        XCTAssertEqual(objectB, objectC)

        objectB.name = "Goodbye"

        XCTAssertNotEqual(objectA, objectC)
    }

    func testEquatableInt() {

        let objectA = Filter(named: "Hello", matching: 1)
        var objectB = Filter(named: "Hello", matching: 1)
        let objectC = Filter(named: "Hello", matching: 2)

        XCTAssertEqual(objectA, objectA)
        XCTAssertEqual(objectA, objectB)
        XCTAssertNotEqual(objectA, objectC)

        objectB.value = .int(2)

        XCTAssertNotEqual(objectA, objectB)
        XCTAssertEqual(objectB, objectC)

        objectB.name = "Goodbye"

        XCTAssertNotEqual(objectA, objectC)
    }

    func testEquatableIntList() {

        let objectA = Filter(named: "Hello", matching: [100, 200, 300])
        var objectB = Filter(named: "Hello", matching: [100, 200, 300])
        let objectC = Filter(named: "Hello", matching: [100, 200])

        XCTAssertEqual(objectA, objectA)
        XCTAssertEqual(objectA, objectB)
        XCTAssertNotEqual(objectA, objectC)

        objectB.value = .intList([100, 200])

        XCTAssertNotEqual(objectA, objectB)
        XCTAssertEqual(objectB, objectC)

        objectB.name = "Goodbye"

        XCTAssertNotEqual(objectA, objectC)
    }

    func testEquatableTimestamp() {

        let dateA = Date()
        let dateB = Date(timeInterval: 100, since: dateA)

        let objectA = Filter(named: "Hello", matching: dateA)
        var objectB = Filter(named: "Hello", matching: dateA)
        let objectC = Filter(named: "Hello", matching: dateB)

        XCTAssertEqual(objectA, objectA)
        XCTAssertEqual(objectA, objectB)
        XCTAssertNotEqual(objectA, objectC)

        objectB.value = .timestamp(dateB)

        XCTAssertNotEqual(objectA, objectB)
        XCTAssertEqual(objectB, objectC)

        objectB.name = "Goodbye"

        XCTAssertNotEqual(objectA, objectC)
    }

    func testQueryItemProvider() {

        // Bool

        var filter = Filter(named: "Bool", matching: true)
        var queryItem = URLQueryItem(name: "Bool", value: "1")
        XCTAssertEqual(filter.queryItem, queryItem)

        // Int

        filter = Filter(named: "Int", matching: 1)
        queryItem = URLQueryItem(name: "Int", value: "1")
        XCTAssertEqual(filter.queryItem, queryItem)

        // Int List

        filter = Filter(named: "IntList", matching: [1, 2, 3])
        queryItem = URLQueryItem(name: "IntList", value: "1,2,3")
        XCTAssertEqual(filter.queryItem, queryItem)

        // Timestamp

        let date = Date()
        filter = Filter(named: "Timestamp", matching: date)
        queryItem = URLQueryItem(name: "Timestamp", value: String(date.secondsSince1970))
        XCTAssertEqual(filter.queryItem, queryItem)
    }

}
