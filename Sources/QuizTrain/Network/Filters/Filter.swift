import Foundation

/*
 Filter results returned by the TestRail API.

 See TestRail's API documentation for allowed name/value pairs, chaining of
 filters, and general usage: http://docs.gurock.com/testrail-api2/start
 */
public struct Filter: Equatable {

    public var name: String
    public var value: Filter.Value

    fileprivate init(name: String, value: Filter.Value) {
        self.name = name
        self.value = value
    }

}

extension Filter {

    public init(named name: String, matching value: Bool) {
        self.init(name: name, value: .bool(value))
    }

    public init(named name: String, matching value: Date) {
        self.init(name: name, value: .timestamp(value))
    }

    public init(named name: String, matching value: Int) {
        self.init(name: name, value: .int(value))
    }

    public init(named name: String, matching value: [Int]) {
        self.init(name: name, value: .intList(value))
    }

}

extension Filter: QueryItemProvider {

    public var queryItem: URLQueryItem {
        return URLQueryItem(name: name, value: value.string)
    }

}
