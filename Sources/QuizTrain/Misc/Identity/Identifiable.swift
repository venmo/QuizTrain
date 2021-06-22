/*
 Provides a way to identify an object. The Id type conforms to Hashable allowing
 for comparison and use in sets.
 */
protocol Identifiable {
    associatedtype Id: Hashable
    var id: Id { get }
}
