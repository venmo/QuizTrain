## XCTestCase Protocol Extensions

Apple's testing framework is unable to identify `test*()` methods defined in protocol extensions applied to `XCTestCase` appearing in a different file than the `XCTestCase`. Because of this methods are defined in protocols appearing in the `../Tests/` group as `_test()` and implemented in a protocol extension. Objects conforming to this protocol must call the corresponding `_test*()` method inside of their `test*()` implementation. For example:

    // SomeProtocol

    func testSomething()
    func _testSomething()

    // SomeProtocol Extension

    func _testSomething() {
        ...test code...
    }

    // Some XCTestCase conforming to SomeProtocol

    func testSomething() {
        _testSomething()
    }
