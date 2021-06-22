import Foundation

/*
 Conforming objects can return a URLQueryItem representation of themselves.
 */
public protocol QueryItemProvider {
    var queryItem: URLQueryItem { get }
    static func queryItems(for providers: [QueryItemProvider]?) -> [URLQueryItem]
}

extension QueryItemProvider {

    public static func queryItems(for providers: [QueryItemProvider]?) -> [URLQueryItem] {
        var queryItems = [URLQueryItem]()
        if let providers = providers {
            for provider in providers {
                queryItems.append(provider.queryItem)
            }
        }
        return queryItems
    }

}
