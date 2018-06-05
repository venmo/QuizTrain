/*
 Provides a container conforming to Error which stores 1+ items also conforming
 to Error. Useful in situations where multiple errors can occur.
 */
public struct ErrorContainer <ErrorType: Error>: Error {

    public let errors: [ErrorType]

    public init(_ error: ErrorType) {
        self.errors = [error]
    }

    public init?(_ errors: [ErrorType]) {
        guard errors.count > 0 else {
            return nil
        }
        self.errors = errors
    }

}

extension ErrorContainer: CustomDebugStringConvertible {

    public var debugDescription: String {
        return "\(errors)"
    }

}

extension ErrorContainer where ErrorType: CustomDebugStringConvertible {

    public var debugDescription: String {
        var description = ""
        for error in errors {
            if description.count == 0 {
                description += error.debugDescription
            } else {
                description += "\n\n\(error.debugDescription)"
            }
        }
        return description
    }

}
