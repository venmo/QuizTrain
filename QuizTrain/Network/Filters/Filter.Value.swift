extension Filter {

    /*
     Value types accepted by the TestRail API used in filters.
     */
    public enum Value {
        case bool(Bool)
        case int(Int)
        case intList([Int])
        case timestamp(Date)
    }

}

extension Filter.Value: Equatable {

    public static func==(lhs: Filter.Value, rhs: Filter.Value) -> Bool {
        switch lhs {
        case .bool(let lhsBool):
            guard case let .bool(rhsBool) = rhs else {
                return false
            }
            return lhsBool == rhsBool
        case .int(let lhsInt):
            guard case let .int(rhsInt) = rhs else {
                return false
            }
            return lhsInt == rhsInt
        case .intList(let lhsIntList):
            guard case let .intList(rhsIntList) = rhs else {
                return false
            }
            return lhsIntList == rhsIntList
        case .timestamp(let lhsDate):
            guard case let .timestamp(rhsDate) = rhs else {
                return false
            }
            return lhsDate.secondsSince1970 == rhsDate.secondsSince1970
        }
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
