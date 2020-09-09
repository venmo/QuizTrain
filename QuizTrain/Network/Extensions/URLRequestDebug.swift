import Foundation

extension URLRequest {

    public var httpBodyAsUTF8: String? {
        guard let httpBody = self.httpBody else {
            return nil
        }
        return String(data: httpBody, encoding: .utf8) ?? nil
    }

    public var httpHeaderFieldsAsMultiLineString: String? {
        return httpHeaderFieldsAsMultiLineString(omittingHeaders: [])
    }

    /*
     Pass |omittedHeaders| to omit any headers. For example ["AUTHORIZATION"]
     if you wish to display/print to logs without leaking sensitive credentials.
     Comparison is performed lowercased() per RFC 7230.
     */
    public func httpHeaderFieldsAsMultiLineString(omittingHeaders omittedHeaders: [String]) -> String? {

        guard let allHTTPHeaderFields = self.allHTTPHeaderFields else {
            return nil
        }

        var httpHeaderFields = ""

        for (field, value) in allHTTPHeaderFields {

            // Headers are case-insensitive per RFC 7230.
            guard omittedHeaders.filter({ $0.lowercased() == field.lowercased() }).count == 0 else {
                continue
            }

            if httpHeaderFields.count > 0 {
                httpHeaderFields += "\n"
            }

            httpHeaderFields += "\(field): \(value)"
        }

        return httpHeaderFields
    }

}
