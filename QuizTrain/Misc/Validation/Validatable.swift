/*
 Provides a way to determine if something is in a valid state. It is up to the
 conformer to determine what is valid or not.
 */
protocol Validatable {
    var isValid: Bool { get }
}
