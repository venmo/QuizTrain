import Foundation

extension Filter {

    /*
     Value types accepted by the TestRail API used in filters.
     */
    public enum Value: Equatable {
        case bool(Bool)
        case int(Int)
        case intList([Int])
        case timestamp(Date)
    }

}

extension Filter.Value {

    public var string: String {
        switch self {
        case .bool(let bool):
            return String(bool ? 1 : 0)
        case .int(let int):
            return String(int)
        case .intList(let intList):
            return intList.compactMap({String($0)}).joined(separator: ",") // [38, 208, 21, 324] ---> "38,208,21,324"
        case .timestamp(let date):
            return String(date.secondsSince1970) // Unix Timestamp as a whole number
        }
    }

}
