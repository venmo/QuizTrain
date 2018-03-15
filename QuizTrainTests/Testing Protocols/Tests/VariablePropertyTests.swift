import XCTest

protocol VariablePropertyTests {

    func testVariableProperties()
    func _testVariableProperties()

}

extension VariablePropertyTests where Self: AssertProperties & ObjectProvider {

    func _testVariableProperties() {
        var object = objectWithRequiredAndOptionalProperties
        assertVariablePropertiesCanBeChanged(in: &object)
    }

}
