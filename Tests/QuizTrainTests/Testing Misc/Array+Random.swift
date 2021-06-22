import Foundation

extension Array {

    public var randomElement: Element? {
        guard let index = randomIndex else {
            return nil
        }
        return self[index]
    }

    public var randomIndex: Int? {
        guard count > 0 else {
            return nil
        }
        return Int(arc4random_uniform(UInt32(count)))
    }

}
