import XCTest
@testable import QuizTrain

protocol JSONDataProvider {

    var requiredJSON: JSONDictionary { get }
    var optionalJSON: JSONDictionary { get }
    var requiredAndOptionalJSON: JSONDictionary { get }

    static var requiredJSON: JSONDictionary { get }
    static var optionalJSON: JSONDictionary { get }
    static var requiredAndOptionalJSON: JSONDictionary { get }
}

extension JSONDataProvider {

    var requiredJSON: JSONDictionary {
        return Self.requiredJSON
    }

    var optionalJSON: JSONDictionary {
        return Self.optionalJSON
    }

    var requiredAndOptionalJSON: JSONDictionary {
        return Self.requiredAndOptionalJSON
    }

    static var requiredAndOptionalJSON: JSONDictionary {
        var dict = Self.requiredJSON
        Self.optionalJSON.forEach { item in dict[item.key] = item.value }
        return dict
    }

}

extension JSONDataProvider where Self: CustomFieldsDataProvider {

    static var requiredAndOptionalJSON: JSONDictionary {
        var dict = Self.requiredJSON
        Self.optionalJSON.forEach { item in dict[item.key] = item.value }
        customFields.forEach { item in dict[item.key] = item.value }
        return dict
    }

}
