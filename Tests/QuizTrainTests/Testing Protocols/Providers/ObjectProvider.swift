import XCTest
@testable import QuizTrain

protocol ObjectProvider {

    associatedtype Object

    var objectWithRequiredProperties: Object { get }
    var objectWithRequiredAndOptionalProperties: Object { get }

    static var objectWithRequiredProperties: Object { get }
    static var objectWithRequiredAndOptionalProperties: Object { get }
}

extension ObjectProvider {

    var objectWithRequiredProperties: Object {
        return Self.objectWithRequiredProperties
    }

    var objectWithRequiredAndOptionalProperties: Object {
        return Self.objectWithRequiredAndOptionalProperties
    }

}

extension ObjectProvider where Self: JSONDataProvider, Object: JSONDeserializable {

    var objectWithRequiredPropertiesFromJSON: Object? {
        return Self.objectWithRequiredPropertiesFromJSON
    }

    var objectWithRequiredAndOptionalPropertiesFromJSON: Object? {
        return Self.objectWithRequiredAndOptionalPropertiesFromJSON
    }

    static var objectWithRequiredPropertiesFromJSON: Object? {
        return Object(json: requiredJSON)
    }

    static var objectWithRequiredAndOptionalPropertiesFromJSON: Object? {
        return Object(json: requiredAndOptionalJSON)
    }

}
