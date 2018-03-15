import Foundation

/*
 Convinience methods for TestRail dates. TestRail dates are always a Unix
 timestamp as a whole number.
 */
extension Date {

    init(secondsSince1970 seconds: Int) {
        self.init(timeIntervalSince1970: TimeInterval(seconds))
    }

    var secondsSince1970: Int {
        return Int(timeIntervalSince1970)
    }

}
