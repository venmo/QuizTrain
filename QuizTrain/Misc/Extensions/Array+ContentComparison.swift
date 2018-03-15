extension Array where Array.Element: Equatable {

    /*
     For an array of Equatable elements, determines if both contain the same
     contents regardless of their ordering.

     let a1 = [1, 2, 2]
     let a2 = [2, 2, 1]
     let a3 = [1, 1, 2]

     a1 == a2 // false
     Array.contentsAreEqual(a1, a2) // true
     Array.contentsAreEqual(a1, a3) // false
     */
    static func contentsAreEqual(_ lhs: [Array.Element]?, _ rhs: [Array.Element]?) -> Bool {
        switch (lhs, rhs) {
        case (.some(let l), .some(let r)):
            return Array.contentsAreEqual(l, r)
        case (.none, .none):
            return true
        default:
            return false
        }
    }

    private static func contentsAreEqual(_ lhs: [Array.Element], _ rhs: [Array.Element]) -> Bool {

        guard lhs.count == rhs.count else {
            return false
        }

        var rhsCopy = rhs
        for item in lhs {
            guard let index = rhsCopy.index(of: item) else {
                return false
            }
            rhsCopy.remove(at: index)
        }

        return true
    }

    func contentsAreEqual(to array: [Array.Element]?) -> Bool {
        return Array.contentsAreEqual(self, array)
    }

}
