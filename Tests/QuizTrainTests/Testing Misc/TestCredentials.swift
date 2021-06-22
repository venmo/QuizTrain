import Foundation

/*
 Represents credentials used in tests. Use the load() method to load data from
 TestCredentials.json.
 */
final class TestCredentials: Codable {
    let hostname: String                                                        // "yourinstance.testrail.net"
    let port: Int                                                               // 443, 80, 8080, etc
    let scheme: String                                                          // "https", "http"
    let secret: String                                                          // Your TestRail API Key or Password
    let username: String                                                        // "your@testrailAccount.email"
}

extension TestCredentials {

    enum LoadError: Error {
        case couldNotFindURLForResourceInBundle(resource: String, extension: String, bundle: Bundle)
        case couldNotLoadDataFromURL(url: URL, error: Error)
        case couldNotDecodeObjectFromJSONData(data: Data, error: Error)
    }

    /*
     Note the Bundle used for tests is different than Bundle.main. Main will not
     be able to see anything inside the test target (e.g. TestCredentials.json).
     Inside a test case load it like so:

     let testCredentials: TestCredentials
     do {
         let bundle = Bundle(for: type(of: self))
         testCredentials = try TestCredentials.load(from: bundle)
     } catch {
         // Handle TestCredentials.LoadError "error"
     }
     */
    static func load(from bundle: Bundle, resource: String = "TestCredentials", withExtension `extension`: String = "json") throws -> TestCredentials {

        guard let url = bundle.url(forResource: resource, withExtension: `extension`) else {
            throw LoadError.couldNotFindURLForResourceInBundle(resource: resource, extension: `extension`, bundle: bundle)
        }

        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw LoadError.couldNotLoadDataFromURL(url: url, error: error)
        }

        let testCredentials: TestCredentials
        do {
            testCredentials = try JSONDecoder().decode(TestCredentials.self, from: data)
        } catch {
            throw LoadError.couldNotDecodeObjectFromJSONData(data: data, error: error)
        }

        return testCredentials
    }

}
