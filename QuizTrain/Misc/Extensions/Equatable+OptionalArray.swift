/*
 Adds == comparison to optional arrays containing an Equatable type.
 */
func ==<Type: Equatable>(lhs: [Type]?, rhs: [Type]?) -> Bool {
    switch (lhs, rhs) {
    case (.some(let l), .some(let r)):
        return l == r
    case (.none, .none):
        return true
    default:
        return false
    }
}
