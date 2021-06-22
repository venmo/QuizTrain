/*
 Provides unique selection state.
 */
enum UniqueSelection<SelectionType: Hashable> {
    case all                                                                    // Include everything.
    case some(Set<SelectionType>)                                               // Include only what's specified.
    case none                                                                   // Include nothing.
}

extension UniqueSelection: Equatable {

    public static func==(lhs: UniqueSelection, rhs: UniqueSelection) -> Bool {
        switch lhs {
        case .all:
            switch rhs {
            case .all:
                return true
            default:
                return false
            }
        case .some(let lhsProjectIds):
            guard case let .some(rhsProjectIds) = rhs else {
                return false
            }
            return lhsProjectIds == rhsProjectIds
        case .none:
            switch rhs {
            case .none:
                return true
            default:
                return false
            }
        }
    }

}
