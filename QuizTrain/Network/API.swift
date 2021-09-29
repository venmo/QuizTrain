import Foundation

/*
 Low-level interface to TestRail's API. Handles authentication, API endpoint
 configuration, creating requests, and returning Outcome's to the consumer of
 this API. This API is dumb and contains no error-handling logic, passing all
 errors to its consumer. The consumer is responsible for handling all errors.

 Interfaces in this class accept basic types such as String, Int, Bool, and Data
 to create and execute calls to the TestRail API. Naming conventions map to url
 schemes rather than Swift naming conventions to make it easier to comprehend
 API documentation.

 For a higher level of abstraction use ObjectAPI.
 */
final public class API: NSObject, URLSessionDelegate {


    // MARK: - Properties

    public var username: String                                                 // your@email.com
    public var secret: String                                                   // Password or API Key
    public var hostname: String                                                 // yourinstance.testrail.net
    public var port: Int                                                        // 443, 80, 8080, etc
    public var scheme: String                                                   // "https" or "http"
    public var path: String
            // /index.php
    public var skipSSL: Bool
    private let session = URLSession(configuration: .`default`)

    // MARK: - Init

    public init(username: String, secret: String, hostname: String, port: Int = 443, scheme: String = "https", path: String = "/index.php", skipSSL: Bool = false) {
        self.username = username
        self.secret = secret
        self.hostname = hostname
        self.port = port
        self.scheme = scheme
        self.path = path
        self.skipSSL = skipSSL
    }

    // MARK: - Deinit

    deinit {
        session.invalidateAndCancel()
    }

    // MARK: - Request Options

    public enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
    }

    // MARK: - URL Components

    private var baseURLComponents: URLComponents {
        var components = URLComponents()
        components.scheme = scheme
        components.host = hostname
        components.path = self.path
        components.port = port
        return components
    }

    private func urlComponents(for uri: String, queryItems: [URLQueryItem]? = nil) -> URLComponents {

        var allQueryItems = [URLQueryItem]()
        let firstQueryItem = URLQueryItem(name: "/api/v2/" + uri, value: nil)
        allQueryItems.append(firstQueryItem)

        if let queryItems = queryItems {
            allQueryItems += queryItems
        }

        var urlComponents = baseURLComponents
        urlComponents.queryItems = allQueryItems

        return urlComponents
    }

    // MARK: - Header Fields

    private func authorization() -> String {
        let usernamePassword = username + ":" + secret
        let usernamePasswordBase64 = Data(usernamePassword.utf8).base64EncodedString()
        return "Basic \(usernamePasswordBase64)"
    }

    // MARK: - URLRequests

    private func testRailRequest(url: URL, cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: TimeInterval = 60.0) -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // All requests require "application/json" Content-Type, including GETs.
        request.setValue(authorization(), forHTTPHeaderField: "Authorization") // All requests require HTTP Basic Authentication.
        return request
    }

    // MARK: - Errors

    public enum RequestError: Error {
        case error(request: URLRequest, error: Error)
        case nilResponse(request: URLRequest)
        case invalidResponse(request: URLRequest, response: URLResponse)
    }

    // MARK: - Results

    public struct RequestResult {
        public let request: URLRequest                                          // Initial unaltered request. Note this will contain the HTTP Basic Authentication credentials. This info is useful for troubleshooting.
        public let response: HTTPURLResponse                                    // Response.
        public let data: Data                                                   // Response data. This will be empty if none was returned.
    }

    // MARK: - Outcomes

    public typealias RequestOutcome = Outcome<RequestResult, RequestError>

    // MARK: - Base Requests

    @discardableResult public func get(_ uri: String, queryItems: [URLQueryItem]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return request(uri, queryItems: queryItems, httpMethod: .get, completionHandler: completionHandler)
    }

    @discardableResult public func post(_ uri: String, queryItems: [URLQueryItem]? = nil, data: Data? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return request(uri, queryItems: queryItems, httpMethod: .post, data: data, completionHandler: completionHandler)
    }

    @discardableResult public func request(_ uri: String, queryItems: [URLQueryItem]? = nil, httpMethod: HttpMethod, data: Data? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        let url = urlComponents(for: uri, queryItems: queryItems).url!
        return request(url: url, httpMethod: httpMethod, data: data, completionHandler: completionHandler)
    }

    private func request(url: URL, httpMethod: HttpMethod, data: Data? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {

        var request = testRailRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = data
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        if !self.skipSSL {
            let session = URLSession(configuration: .`default`)
        }
        let task = session.dataTask(with: request) { (data, response, error) in

            var outcome: RequestOutcome
            defer {
                completionHandler(outcome)
            }

            guard error == nil else {
                outcome = .failure(.error(request: request, error: error!))
                return
            }

            guard let response = response else {
                outcome = .failure(.nilResponse(request: request))
                return
            }

            guard let urlResponse = response as? HTTPURLResponse else {
                outcome = .failure(.invalidResponse(request: request, response: response))
                return
            }

            let data = data ?? Data()

            outcome = .success(RequestResult(request: request, response: urlResponse, data: data))
        }

        task.resume()
        return task
    }

    // MARK: - Cases

    /*
     http://docs.gurock.com/testrail-api2/reference-cases#add_case
     */
    @discardableResult public func addCase(sectionId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_case/\(sectionId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-cases#delete_case
     */
    @discardableResult public func deleteCase(caseId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_case/\(caseId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-cases#get_case
     */
    @discardableResult public func getCase(caseId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_case/\(caseId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-cases#get_cases
     */
    @discardableResult public func getCases(projectId: Int, suiteId: Int? = nil, sectionId: Int? = nil, filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {

        var queryItems = [URLQueryItem]()

        if let suiteId = suiteId {
            queryItems.append(URLQueryItem(name: "suite_id", value: String(suiteId)))
        }

        if let sectionId = sectionId {
            queryItems.append(URLQueryItem(name: "section_id", value: String(sectionId)))
        }

        if let filters = filters {
            _ = filters.compactMap { queryItems.append($0.queryItem) }
        }

        return get("get_cases/\(projectId)", queryItems: queryItems, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-cases#update_case
     */
    @discardableResult public func updateCase(caseId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_case/\(caseId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Case Fields

    /*
     http://docs.gurock.com/testrail-api2/reference-cases-fields#add_case_field
     */
    @discardableResult public func addCaseField(data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_case_field", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-cases-fields#get_case_fields
     */
    @discardableResult public func getCaseFields(completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_case_fields", completionHandler: completionHandler)
    }

    // MARK: - Case Types

    /*
     http://docs.gurock.com/testrail-api2/reference-cases-types#get_case_types
     */
    @discardableResult public func getCaseTypes(completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_case_types", completionHandler: completionHandler)
    }

    // MARK: - Configurations

    /*
     http://docs.gurock.com/testrail-api2/reference-configs#add_config
     */
    @discardableResult public func addConfiguration(configurationGroupId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_config/\(configurationGroupId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-configs#delete_config
     */
    @discardableResult public func deleteConfiguration(configurationId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_config/\(configurationId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-configs#get_configs
     */
    @discardableResult public func getConfigurations(projectId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_configs/\(projectId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-configs#update_config
     */
    @discardableResult public func updateConfiguration(configurationId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_config/\(configurationId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Configuration Groups

    /*
     http://docs.gurock.com/testrail-api2/reference-configs#add_config_group
     */
    @discardableResult public func addConfigurationGroup(projectId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_config_group/\(projectId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-configs#delete_config_group
     */
    @discardableResult public func deleteConfigurationGroup(configurationGroupId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_config_group/\(configurationGroupId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-configs#update_config_group
     */
    @discardableResult public func updateConfigurationGroup(configurationGroupId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_config_group/\(configurationGroupId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Milestones

    /*
     http://docs.gurock.com/testrail-api2/reference-milestones#add_milestone
     */
    @discardableResult public func addMilestone(projectId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_milestone/\(projectId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-milestones#delete_milestone
     */
    @discardableResult public func deleteMilestone(milestoneId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_milestone/\(milestoneId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-milestones#get_milestone
     */
    @discardableResult public func getMilestone(milestoneId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_milestone/\(milestoneId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-milestones#get_milestones
     */
    @discardableResult public func getMilestones(projectId: Int, filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_milestones/\(projectId)", queryItems: Filter.queryItems(for: filters), completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-milestones#update_milestone
     */
    @discardableResult public func updateMilestone(milestoneId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_milestone/\(milestoneId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Plans

    /*
     http://docs.gurock.com/testrail-api2/reference-plans#add_plan
     */
    @discardableResult public func addPlan(projectId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_plan/\(projectId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-plans#close_plan
     */
    @discardableResult public func closePlan(planId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("close_plan/\(planId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-plans#delete_plan
     */
    @discardableResult public func deletePlan(planId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_plan/\(planId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-plans#get_plan
     */
    @discardableResult public func getPlan(planId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_plan/\(planId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-plans#get_plans
     */
    @discardableResult public func getPlans(projectId: Int, filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_plans/\(projectId)", queryItems: Filter.queryItems(for: filters), completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-plans#update_plan
     */
    @discardableResult public func updatePlan(planId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_plan/\(planId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Plan Entries

    /*
     http://docs.gurock.com/testrail-api2/reference-plans#add_plan_entry
     */
    @discardableResult public func addPlanEntry(planId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_plan_entry/\(planId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-plans#delete_plan_entry
     */
    @discardableResult public func deletePlanEntry(planId: Int, planEntryId: String, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_plan_entry/\(planId)/\(planEntryId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-plans#update_plan_entry
     */
    @discardableResult public func updatePlanEntry(planId: Int, planEntryId: String, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_plan_entry/\(planId)/\(planEntryId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Priorities

    /*
     http://docs.gurock.com/testrail-api2/reference-priorities#get_priorities
     */
    @discardableResult public func getPriorities(completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_priorities", completionHandler: completionHandler)
    }

    // MARK: - Projects

    /*
     http://docs.gurock.com/testrail-api2/reference-projects#add_project
     */
    @discardableResult public func addProject(data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_project", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-projects#delete_project
     */
    @discardableResult public func deleteProject(projectId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_project/\(projectId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-projects#get_project
     */
    @discardableResult public func getProject(projectId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_project/\(projectId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-projects#get_projects
     */
    @discardableResult public func getProjects(filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_projects", queryItems: Filter.queryItems(for: filters), completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-projects#update_project
     */
    @discardableResult public func updateProject(projectId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_project/\(projectId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Results

    /*
     http://docs.gurock.com/testrail-api2/reference-results#add_result
     */
    @discardableResult public func addResult(testId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_result/\(testId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-results#add_result_for_case
     */
    @discardableResult public func addResultForCase(runId: Int, caseId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_result_for_case/\(runId)/\(caseId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-results#add_results
     */
    @discardableResult public func addResults(runId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_results/\(runId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-results#add_results_for_cases
     */
    @discardableResult public func addResultsForCases(runId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_results_for_cases/\(runId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-results#get_results
     */
    @discardableResult public func getResults(testId: Int, filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_results/\(testId)", queryItems: Filter.queryItems(for: filters), completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-results#get_results_for_case
     */
    @discardableResult public func getResultsForCase(runId: Int, caseId: Int, filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_results_for_case/\(runId)/\(caseId)", queryItems: Filter.queryItems(for: filters), completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-results#get_results_for_run
     */
    @discardableResult public func getResultsForRun(runId: Int, filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_results_for_run/\(runId)", queryItems: Filter.queryItems(for: filters), completionHandler: completionHandler)
    }

    // MARK: - Result Fields

    /*
     http://docs.gurock.com/testrail-api2/reference-results-fields#get_result_fields
     */
    @discardableResult public func getResultFields(completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_result_fields", completionHandler: completionHandler)
    }

    // MARK: - Runs

    /*
     http://docs.gurock.com/testrail-api2/reference-runs#add_run
     */
    @discardableResult public func addRun(projectId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_run/\(projectId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-runs#close_run
     */
    @discardableResult public func closeRun(runId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("close_run/\(runId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-runs#delete_run
     */
    @discardableResult public func deleteRun(runId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_run/\(runId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-runs#get_run
     */
    @discardableResult public func getRun(runId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_run/\(runId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-runs#get_runs
     */
    @discardableResult public func getRuns(projectId: Int, filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_runs/\(projectId)", queryItems: Filter.queryItems(for: filters), completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-runs#update_run
     */
    @discardableResult public func updateRun(runId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_run/\(runId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Sections

    /*
     http://docs.gurock.com/testrail-api2/reference-sections#add_section
     */
    @discardableResult public func addSection(projectId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_section/\(projectId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-sections#delete_section
     */
    @discardableResult public func deleteSection(sectionId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_section/\(sectionId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-sections#get_section
     */
    @discardableResult public func getSection(sectionId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_section/\(sectionId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-sections#get_sections
     */
    @discardableResult public func getSections(projectId: Int, suiteId: Int? = nil, filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        var queryItems = [URLQueryItem]()

        if let suiteId = suiteId {
            queryItems.append(URLQueryItem(name: "suite_id", value: String(suiteId)))
        }
        
        if let filters = filters {
            _ = filters.compactMap { queryItems.append($0.queryItem) }
        }
        return get("get_sections/\(projectId)", queryItems: queryItems, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-sections#update_section
     */
    @discardableResult public func updateSection(sectionId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_section/\(sectionId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Statuses

    /*
     http://docs.gurock.com/testrail-api2/reference-statuses#get_statuses
     */
    @discardableResult public func getStatuses(completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_statuses", completionHandler: completionHandler)
    }

    // MARK: - Suites

    /*
     http://docs.gurock.com/testrail-api2/reference-suites#add_suite
     */
    @discardableResult public func addSuite(projectId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("add_suite/\(projectId)", data: data, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-suites#delete_suite
     */
    @discardableResult public func deleteSuite(suiteId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("delete_suite/\(suiteId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-suites#get_suite
     */
    @discardableResult public func getSuite(suiteId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_suite/\(suiteId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-suites#get_suites
     */
    @discardableResult public func getSuites(projectId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_suites/\(projectId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-suites#update_suite
     */
    @discardableResult public func updateSuite(suiteId: Int, data: Data, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return post("update_suite/\(suiteId)", data: data, completionHandler: completionHandler)
    }

    // MARK: - Templates

    /*
     http://docs.gurock.com/testrail-api2/reference-templates#get_templates
     */
    @discardableResult public func getTemplates(projectId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_templates/\(projectId)", completionHandler: completionHandler)
    }

    // MARK: - Tests

    /*
     http://docs.gurock.com/testrail-api2/reference-tests#get_test
     */
    @discardableResult public func getTest(testId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_test/\(testId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-tests#get_tests
     */
    @discardableResult public func getTests(runId: Int, filters: [Filter]? = nil, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_tests/\(runId)", queryItems: Filter.queryItems(for: filters), completionHandler: completionHandler)
    }

    // MARK: - Users

    /*
     http://docs.gurock.com/testrail-api2/reference-users#get_user
     */
    @discardableResult public func getUser(userId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_user/\(userId)", completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-users#get_user_by_email
     */
    @discardableResult public func getUserByEmail(_ email: String, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        let queryItems = [URLQueryItem(name: "email", value: email)]
        return get("get_user_by_email", queryItems: queryItems, completionHandler: completionHandler)
    }

    /*
     http://docs.gurock.com/testrail-api2/reference-users#get_users
     */
    @discardableResult public func getUsers(_ projectId: Int, completionHandler: @escaping (RequestOutcome) -> Void) -> URLSessionDataTask {
        return get("get_users/\(projectId)", completionHandler: completionHandler)
    }

}

extension API {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
            return
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}
