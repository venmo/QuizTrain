import XCTest

protocol AssertProperties {
    associatedtype Object
    func assertRequiredProperties(in object: Object)
    func assertOptionalProperties(in object: Object, areNil: Bool)
    func assertVariablePropertiesCanBeChanged(in object: inout Object)
}
