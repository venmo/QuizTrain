import Foundation

// MARK: - Properties & Init

/*
 Mid-level interface to TestRail's API. This class builds on top of API by
 working with model objects and provides 429 Too Many Requests retry handling
 when rate limits are reached when handle429TooManyRequestErrors is true. It
 abstracts you away from having to deal with Data, JSON, and serialization &
 deserialization of objects. In some cases it handles async API calls where a
 single call is not possible. A completion handler is called either with a
 succeeded or failed outcome on an undefined queue.

 Succeeded outcomes:

 - Add requests return a newly created single or multiple objects.
 - Close requests return a newly created closed object.
 - Delete requests return nil.
 - Get requests return a single or multiple objects. They can be nil in some
   cases.
 - Update requests return a newly updated object.

 Failed outcomes:

 Failed outcomes return an error or ErrorContainer if multiple errors can occur.
 See "Errors" extension for details. The consumer of this class is responsible
 for handling all errors. However this class will handle 429 Too Many Request
 errors automatically when handle429TooManyRequestErrors is true.

 NOTE: Certain API calls will return nil or partial-data for some object
 properties. For example getPlans(...) will always return nil for Plan.entries,
 but getPlan(...) will not if the plan has any entries. While this type of
 behavior is documented here when known, the single source of truth will always
 be in TestRail's official API docs: http://docs.gurock.com/testrail-api2/start
 */
final public class ObjectAPI {

    public let api: API

    fileprivate let asyncRequestQueue: OperationQueue

    public var asyncRequestQueueQoS: QualityOfService {
        get { return asyncRequestQueue.qualityOfService }
        set { asyncRequestQueue.qualityOfService = newValue }
    }

    public var asyncRequestQueueMaxConcurrentOperationCount: NSInteger {
        get { return asyncRequestQueue.maxConcurrentOperationCount }
        set { asyncRequestQueue.maxConcurrentOperationCount = newValue }
    }

    public var handle429TooManyRequestErrors: Bool = true
    fileprivate let retryQueue: DispatchQueue

    public init(api: API, retryQueueQoS: DispatchQoS = .`default`) {
        self.api = api
        self.asyncRequestQueue = OperationQueue()
        self.asyncRequestQueue.name = "ObjectAPI.asyncRequestQueue"
        self.retryQueue = DispatchQueue(label: "ObjectAPI.retryQueue", qos: retryQueueQoS)
    }

    public convenience init(username: String, secret: String, hostname: String, port: Int = 443, scheme: String = "https", retryQueueQoS: DispatchQoS = .`default`, path: String = "/index.php", skipSSL: Bool = false) {
        let api = API(username: username, secret: secret, hostname: hostname, port: port, scheme: scheme, path: path, skipSSL: skipSSL)
        self.init(api: api, retryQueueQoS: retryQueueQoS)
    }

    deinit {
        asyncRequestQueue.cancelAllOperations()
    }

}

// MARK: - Errors

extension ObjectAPI {

    // MARK: Status Code

    public struct ClientError {
        public var statusCode: Int { return requestResult.response.statusCode } // 400...499
        public let message: String                                              // Body or error message extracted from response. Could be empty.
        public let requestResult: API.RequestResult
    }

    public struct ServerError {
        public var statusCode: Int { return requestResult.response.statusCode } // 500...599
        public let message: String                                              // Body extracted from response. Could be empty.
        public let requestResult: API.RequestResult
    }

    // MARK: Base

    public enum StatusCodeError: Error {
        case clientError(ClientError)                                           // 400...499
        case serverError(ServerError)                                           // 500...599
        case otherError(API.RequestResult)                                      // Any other status code which is not any of the above or 200...299.
    }

    public enum DataProcessingError: Error {
        case couldNotConvertDataToJSON(data: Data, error: Error)                // TestRail returned data which is not valid UTF8 encoded JSON.
        case invalidJSONFormat(json: Any)                                       // TestRail returned valid UTF8 encoded JSON but it could not be converted into an expected JSON format.
        case couldNotDeserializeFromJSON(objectType: Any.Type, json: Any)       // TestRail returned valid UTF8 encoded JSON but it could not be deserialized into an object or objects. This might mean a model needs to be updated.
    }

    public enum ObjectConversionError: Error {
        case couldNotConvertObjectToData(object: Any, json: JSONDictionary, error: Error)       // An error occurred converting the object to Data from its JSON representation.
        case couldNotConvertObjectsToData(objects: [Any], json: JSONDictionary, error: Error)   // An error occurred converting the objects to Data from their JSON representations.
    }

    // MARK: Low Level

    public enum RequestError: Error {
        case apiError(API.RequestError)
        case statusCodeError(StatusCodeError)
    }

    public enum DataRequestError: Error {
        case apiError(API.RequestError)
        case statusCodeError(StatusCodeError)
        case dataProcessingError(DataProcessingError)
    }

    public enum UpdateRequestError: Error {
        case objectConversionError(ObjectConversionError)
        case apiError(API.RequestError)
        case statusCodeError(StatusCodeError)
        case dataProcessingError(DataProcessingError)
    }

    // MARK: High Level

    public typealias AddError = UpdateRequestError
    public typealias CloseError = DataRequestError
    public typealias DeleteError = RequestError
    public typealias GetError = DataRequestError
    public typealias UpdateError = UpdateRequestError

    // MARK: Matching

    public enum MatchError<MatchErrorType, OtherErrorType>: Error {
        case matchError(MatchErrorType)
        case otherError(OtherErrorType)
    }

}

// MARK: - API.RequestOutcome Handling

extension ObjectAPI {

    // MARK: RequestOutcome

    private typealias RequestOutcome = Outcome<API.RequestResult, RequestError>

    /**
     Converts an API.RequestOutcome into a more strongly-defined RequestOutcome.
     */
    private static func requestOutcome(from apiRequestOutcome: API.RequestOutcome) -> RequestOutcome {

        let requestResult: API.RequestResult
        switch apiRequestOutcome {
        case .success(let aRequestResult):
            requestResult = aRequestResult
        case .failure(let error):
            return .failure(.apiError(error))
        }

        switch requestResult.response.statusCode {
        case 200...299:
            return .success(requestResult)
        case 400...499:
            let message: String
            let json = try? JSONSerialization.jsonObject(with: requestResult.data, options: [])
            if let json = json as? JSONDictionary, let jsonError = json["error"] as? String { // TestRail typically returns {"error": "Some error message."} as JSON.
                message = jsonError
            } else {
                message = String(data: requestResult.data, encoding: .utf8) ?? "" // If no JSON error can be extracted attempt to decode as UTF8.
            }
            let clientError = ClientError(message: message, requestResult: requestResult)
            return .failure(.statusCodeError(.clientError(clientError)))
        case 500...599:
            let message = String(data: requestResult.data, encoding: .utf8) ?? ""
            let serverError = ServerError(message: message, requestResult: requestResult)
            return .failure(.statusCodeError(.serverError(serverError)))
        default:
            return .failure(.statusCodeError(.otherError(requestResult)))
        }
    }

    // MARK: JSON

    private typealias JSONOutcome = Outcome<Any, DataRequestError>

    /**
     Attempts to extract JSON from `apiRequestOutcome` and return it. If
     extraction fails a failed JSONOutcome is returned.
     */
    private static func json(from apiRequestOutcome: API.RequestOutcome) -> JSONOutcome {

        let requestOutcome = ObjectAPI.requestOutcome(from: apiRequestOutcome)

        let data: Data
        switch requestOutcome {
        case .failure(let error):
            switch error {
            case .apiError(let apiError):
                return .failure(.apiError(apiError))
            case .statusCodeError(let statusCodeError):
                return .failure(.statusCodeError(statusCodeError))
            }
        case .success(let requestResult):
            data = requestResult.data
        }

        let json: Any
        do {
            json = try JSONSerialization.jsonObject(with: data)
        } catch {
            return .failure(.dataProcessingError(.couldNotConvertDataToJSON(data: data, error: error)))
        }

        return .success(json)
    }

    // MARK: Object(s)

    private typealias ObjectOutcome<ObjectType> = Outcome<ObjectType, DataRequestError>
    private typealias ObjectsOutcome<ObjectType> = Outcome<[ObjectType], DataRequestError>

    /**
     Attempts to deserialize and return an object of ObjectType from
     `apiRequestOutcome`. If deserializing fails a failed ObjectOutcome is
     returned.
     */
    private static func object<ObjectType: JSONDeserializable>(from apiRequestOutcome: API.RequestOutcome) -> ObjectOutcome<ObjectType> {

        let jsonOutcome = ObjectAPI.json(from: apiRequestOutcome)

        let json: Any
        switch jsonOutcome {
        case .failure(let error):
            return .failure(error)
        case .success(let aJson):
            json = aJson
        }

        guard let jsonDictionary = json as? JSONDictionary else {
            return .failure(.dataProcessingError(.invalidJSONFormat(json: json)))
        }

        guard let object: ObjectType = ObjectType.deserialized(jsonDictionary) else {
            return .failure(.dataProcessingError(.couldNotDeserializeFromJSON(objectType: ObjectType.self, json: jsonDictionary)))
        }

        return .success(object)
    }

    /**
     Attempts to deserialize and return 0+ objects of ObjectType from
     `apiRequestOutcome`. If deserializing fails a failed ObjectsOutcome is
     returned.
     */
    private static func object<ObjectType: JSONDeserializable>(from apiRequestOutcome: API.RequestOutcome) -> ObjectsOutcome<ObjectType> {

        let jsonOutcome = ObjectAPI.json(from: apiRequestOutcome)

        let json: Any
        switch jsonOutcome {
        case .failure(let error):
            return .failure(error)
        case .success(let aJson):
            json = aJson
        }

        guard let jsonArray = json as? [JSONDictionary] else {
            return .failure(.dataProcessingError(.invalidJSONFormat(json: json)))
        }

        guard let objects: [ObjectType] = ObjectType.deserialized(jsonArray) else {
            return .failure(.dataProcessingError(.couldNotDeserializeFromJSON(objectType: ObjectType.self, json: jsonArray)))
        }

        return .success(objects)
    }

    // MARK: Rate Limit

    /**
     Helper for processing 429 Too Many Requests errors.
     */
    private struct RateLimitReached {

        let retryAfter: UInt

        init?(clientError: ClientError) {
            guard clientError.statusCode == 429 else {
                return nil
            }
            self.retryAfter = clientError.requestResult.response.allHeaderFields["Retry-After"] as? UInt ?? 5 // Default to 5 seconds if Retry-After is missing.
        }

    }

    // MARK: Processing

    /**
     These methods handle processing an API.RequestOutcome calling one of the
     handler closures when complete. Swift inference auto-detects which
     process(...) method to call.

     The value passed to a Outcome.success and .failed cases varies. See
     method comments for details.

     If handle429TooManyRequestErrors is true and the API returned a 429 Too
     Many Requests error, the `retryHandler` will be called after waiting the
     API-specified wait time. The caller of a method should re-call itself in
     this closure passing itself the same arguments it received for proper retry
     behavior.

     In all other cases the `completionHandler` is called when complete.
     */

    /**
     Process API.RequestOutcome's to delete an object.

     - Outcome.success receives an API.DataResponse.
     - Outcome.failure receives a RequestError.
     */
    fileprivate func process(_ apiRequestOutcome: API.RequestOutcome, retryHandler: @escaping (() -> Void), completionHandler: @escaping (Outcome<API.RequestResult, RequestError>) -> Void) {

        let requestOutcome = ObjectAPI.requestOutcome(from: apiRequestOutcome)

        switch requestOutcome {
        case .failure(let error):
            switch error {
            case .statusCodeError(.clientError(let clientError)):
                if let rateLimitReached = RateLimitReached(clientError: clientError), handle429TooManyRequestErrors {
                    retryQueue.asyncAfter(deadline: DispatchTime.now() + Double(rateLimitReached.retryAfter)) {
                        retryHandler()
                    }
                } else {
                    completionHandler(.failure(error))
                }
            default:
                completionHandler(.failure(error))
            }
        case .success(let success):
            completionHandler(.success(success))
        }
    }

    /**
     Process API.RequestOutcome's to get a single object.

     - Outcome.success receives an object deserialized from
       API.RequestOutcome.
     - Outcome.failure receives a DataRequestError.
     */
    fileprivate func process<ObjectType: JSONDeserializable>(_ apiRequestOutcome: API.RequestOutcome, retryHandler: @escaping (() -> Void), completionHandler: @escaping (Outcome<ObjectType, DataRequestError>) -> Void) {

        let objectOutcome: ObjectOutcome<ObjectType> = ObjectAPI.object(from: apiRequestOutcome)

        switch objectOutcome {
        case .failure(let error):
            switch error {
            case .statusCodeError(.clientError(let clientError)):
                if let rateLimitReached = RateLimitReached(clientError: clientError), handle429TooManyRequestErrors {
                    retryQueue.asyncAfter(deadline: DispatchTime.now() + Double(rateLimitReached.retryAfter)) {
                        retryHandler()
                    }
                } else {
                    completionHandler(.failure(error))
                }
            default:
                completionHandler(.failure(error))
            }
        case .success(let success):
            completionHandler(.success(success))
        }
    }

    /**
     Process API.RequestOutcome's to get multiple objects.

     - Outcome.success receives 0+ object(s) deserialized from
       API.RequestOutcome.
     - Outcome.failure receives a DataRequestError.
     */
    fileprivate func process<ObjectType: JSONDeserializable>(_ apiRequestOutcome: API.RequestOutcome, retryHandler: @escaping (() -> Void), completionHandler: @escaping (Outcome<[ObjectType], DataRequestError>) -> Void) {

        let objectOutcome: ObjectOutcome<[ObjectType]> = ObjectAPI.object(from: apiRequestOutcome)

        switch objectOutcome {
        case .failure(let error):
            switch error {
            case .statusCodeError(.clientError(let clientError)):
                if let rateLimitReached = RateLimitReached(clientError: clientError), handle429TooManyRequestErrors {
                    retryQueue.asyncAfter(deadline: DispatchTime.now() + Double(rateLimitReached.retryAfter)) {
                        retryHandler()
                    }
                } else {
                    completionHandler(.failure(error))
                }
            default:
                completionHandler(.failure(error))
            }
        case .success(let success):
            completionHandler(.success(success))
        }
    }

    /**
     Process API.RequestOutcome's to add or update an object returning a new
     added/updated object if successful.

     - Outcome.success receives an object deserialized from
       API.RequestOutcome.
     - Outcome.failure receives an UpdateRequestError.
     */
    fileprivate func process<ObjectType: JSONDeserializable>(_ apiRequestOutcome: API.RequestOutcome, retryHandler: @escaping (() -> Void), completionHandler: @escaping (Outcome<ObjectType, UpdateRequestError>) -> Void) {

        let objectOutcome: ObjectOutcome<ObjectType> = ObjectAPI.object(from: apiRequestOutcome)

        switch objectOutcome {
        case .failure(let error):
            switch error {
            case .apiError(let apiError):
                completionHandler(.failure(.apiError(apiError)))
            case .statusCodeError(.clientError(let clientError)):
                if let rateLimitReached = RateLimitReached(clientError: clientError), handle429TooManyRequestErrors {
                    retryQueue.asyncAfter(deadline: DispatchTime.now() + Double(rateLimitReached.retryAfter)) {
                        retryHandler()
                    }
                } else {
                    completionHandler(.failure(.statusCodeError(.clientError(clientError))))
                }
            case .statusCodeError(let statusCodeError):
                completionHandler(.failure(.statusCodeError(statusCodeError)))
            case .dataProcessingError(let dataProcessingError):
                completionHandler(.failure(.dataProcessingError(dataProcessingError)))
            }
        case .success(let success):
            completionHandler(.success(success))
        }
    }

    /**
     Process API.RequestOutcome's to add or update multiple objects returning an
     array of the added/updated objects if successful.

     - Outcome.success receives an array of objects deserialized from
       API.RequestOutcome.
     - Outcome.failure receives an UpdateRequestError.
     */
    fileprivate func process<ObjectType: JSONDeserializable>(_ apiRequestOutcome: API.RequestOutcome, retryHandler: @escaping (() -> Void), completionHandler: @escaping (Outcome<[ObjectType], UpdateRequestError>) -> Void) {

        let objectOutcome: ObjectOutcome<[ObjectType]> = ObjectAPI.object(from: apiRequestOutcome)

        switch objectOutcome {
        case .failure(let error):
            switch error {
            case .apiError(let apiError):
                completionHandler(.failure(.apiError(apiError)))
            case .statusCodeError(.clientError(let clientError)):
                if let rateLimitReached = RateLimitReached(clientError: clientError), handle429TooManyRequestErrors {
                    retryQueue.asyncAfter(deadline: DispatchTime.now() + Double(rateLimitReached.retryAfter)) {
                        retryHandler()
                    }
                } else {
                    completionHandler(.failure(.statusCodeError(.clientError(clientError))))
                }
            case .statusCodeError(let statusCodeError):
                completionHandler(.failure(.statusCodeError(statusCodeError)))
            case .dataProcessingError(let dataProcessingError):
                completionHandler(.failure(.dataProcessingError(dataProcessingError)))
            }
        case .success(let success):
            completionHandler(.success(success))
        }
    }
}

// MARK: - Object to JSON to Data

extension ObjectAPI {

    fileprivate typealias DataOutcome = Outcome<Data, ObjectConversionError>

    fileprivate func data(from object: AddRequestJSON) -> DataOutcome {

        let json = object.addRequestJSON

        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: json, options: [])
        } catch {
            return .failure(.couldNotConvertObjectToData(object: object, json: json, error: error))
        }

        return .success(data)
    }

    fileprivate func data(from object: UpdateRequestJSON) -> DataOutcome {

        let json = object.updateRequestJSON

        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: json, options: [])
        } catch {
            return .failure(.couldNotConvertObjectToData(object: object, json: json, error: error))
        }

        return .success(data)
    }

    /**
     Combines JSON from all `objects` and returns Data from it. Any overlapping
     JSON keys are overriden by the last-most object in `objects`.
     */
    fileprivate func data(from objects: [UpdateRequestJSON]) -> DataOutcome {

        var json: JSONDictionary = [:]
        for object in objects {
            let objectJson = object.updateRequestJSON
            objectJson.forEach { item in json[item.key] = item.value }
        }

        let data: Data
        do {
            data = try JSONSerialization.data(withJSONObject: json, options: [])
        } catch {
            return .failure(.couldNotConvertObjectsToData(objects: objects, json: json, error: error))
        }

        return .success(data)
    }

}

// MARK: - Objects (Fileprivate Outcomes)

extension ObjectAPI {

    // MARK: - ConfigurationGroup

    /**
     Queries all Project's matching |projectIds| asynchronously to get their
     ConfigurationGroups. Passes a dictionary of outcomes to the
     completionHandler mapping projectIds to each outcome when complete:

     [projectId1: outcome1, projectId2: outcome2, ...]

     The totality of outcomes can be in three states:

     1. All outcomes succeeded.
     2. All outcomes failed.
     3. Outcomes are a mixture of succeeded/failed states.

     It is up to the consumer of this method to determine how to handle #2/3.
     */
    fileprivate func getConfigurationGroups(inProjectsWithIds projectIds: Set<Project.Id>, completionHandler: @escaping ([Project.Id: Outcome<[ConfigurationGroup], GetError>]) -> Void) {

        // For every project create an operation to get all of its configuration groups.
        var operations = [GetConfigurationGroupsOperation]()
        for projectId in projectIds {
            let operation = GetConfigurationGroupsOperation(api: self, projectId: projectId)
            operations.append(operation)
        }

        let completedOperation = BlockOperation {

            // Nothing should be cancelled. The asyncRequestQueue is fileprivate
            // and will only be cancelled if the ObjectAPI is deinit'ed.
            guard operations.filter({ $0.isCancelled == true }).count == 0 else {
                return
            }

            // Everything must have finished.
            guard operations.filter({ $0.isFinished == true }).count == operations.count else {
                return
            }

            var allOutcomes = [Project.Id: Outcome<[ConfigurationGroup], GetError>]()
            for operation in operations {
                allOutcomes[operation.projectId] = operation.outcome
            }

            completionHandler(allOutcomes)
        }

        for operation in operations {
            completedOperation.addDependency(operation)
        }

        var allOperations: [Operation] = operations
        allOperations.append(completedOperation)

        asyncRequestQueue.addOperations(allOperations, waitUntilFinished: false)
    }

    // MARK: - Project

    /**
     Asynchronously GETs each project in |projectIds|. Passes a dictionary of
     outcomes to the completionHandler mapping projectIds to each outcome when
     complete:

     [projectId1: outcome1, projectId2: outcome2, ...]

     The totality of outcomes can be in three states:

     1. All outcomes succeeded.
     2. All outcomes failed.
     3. Outcomes are a mixture of succeeded/failed states.

     It is up to the consumer of this method to determine how to handle #2/3.

     403 failure errors indicate an authorization issue (you do not have at
     least "Read-only" access to that project). It is possible for a project to
     have "No Access" set preventing anyone from accessing it.
     */
    fileprivate func getProjects(_ projectIds: Set<Project.Id>, completionHandler: @escaping ([Project.Id: Outcome<Project, GetError>]) -> Void) {

        // Create an operation to get each project.
        var operations = [GetProjectOperation]()
        for projectId in projectIds {
            let operation = GetProjectOperation(api: self, projectId: projectId)
            operations.append(operation)
        }

        let completedOperation = BlockOperation {

            // Nothing should be cancelled. The asyncRequestQueue is fileprivate
            // and will only be cancelled if the ObjectAPI is deinit'ed.
            guard operations.filter({ $0.isCancelled == true }).count == 0 else {
                return
            }

            // Everything must have finished.
            guard operations.filter({ $0.isFinished == true }).count == operations.count else {
                return
            }

            var allOutcomes = [Project.Id: Outcome<Project, GetError>]()
            for operation in operations {
                allOutcomes[operation.projectId] = operation.outcome
            }

            completionHandler(allOutcomes)
        }

        for operation in operations {
            completedOperation.addDependency(operation)
        }

        var allOperations: [Operation] = operations
        allOperations.append(completedOperation)

        asyncRequestQueue.addOperations(allOperations, waitUntilFinished: false)
    }

    // MARK: - Template

    /**
     Queries all Project's matching |projectIds| asynchronously to get their
     Templates. Passes a dictionary of outcomes to the completionHandler
     mapping projectIds to each outcome when complete:

     [projectId1: outcome1, projectId2: outcome2, ...]

     The totality of outcomes can be in three states:

     1. All outcomes succeeded.
     2. All outcomes failed.
     3. Outcomes are a mixture of succeeded/failed states.

     It is up to the consumer of this method to determine how to handle #2/3.
     */
    fileprivate func getTemplates(inProjectsWithIds projectIds: Set<Project.Id>, completionHandler: @escaping ([Project.Id: Outcome<[Template], GetError>]) -> Void) {

        // For every project create an operation to get all of its templates.
        var operations = [GetTemplatesOperation]()
        for projectId in projectIds {
            let operation = GetTemplatesOperation(api: self, projectId: projectId)
            operations.append(operation)
        }

        let completedOperation = BlockOperation {

            // Nothing should be cancelled. The asyncRequestQueue is fileprivate
            // and will only be cancelled if the ObjectAPI is deinit'ed.
            guard operations.filter({ $0.isCancelled == true }).count == 0 else {
                return
            }

            // Everything must have finished.
            guard operations.filter({ $0.isFinished == true }).count == operations.count else {
                return
            }

            var allOutcomes = [Project.Id: Outcome<[Template], GetError>]()
            for operation in operations {
                allOutcomes[operation.projectId] = operation.outcome
            }

            completionHandler(allOutcomes)
        }

        for operation in operations {
            completedOperation.addDependency(operation)
        }

        var allOperations: [Operation] = operations
        allOperations.append(completedOperation)

        asyncRequestQueue.addOperations(allOperations, waitUntilFinished: false)
    }

}

// MARK: - Objects

extension ObjectAPI {

    // MARK: - Case

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases#add_case)
     */
    public func addCase(_ newCase: NewCase, to section: Section, completionHandler: @escaping (Outcome<Case, AddError>) -> Void) {
        addCase(newCase, toSectionWithId: section.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases#add_case)
     */
    public func addCase(_ newCase: NewCase, toSectionWithId sectionId: Section.Id, completionHandler: @escaping (Outcome<Case, AddError>) -> Void) {

        let dataOutcome = self.data(from: newCase)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addCase(sectionId: sectionId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addCase(newCase, toSectionWithId: sectionId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases#delete_case)
     */
    public func deleteCase(_ case: Case, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deleteCase(`case`.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases#delete_case)
     */
    public func deleteCase(_ caseId: Case.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deleteCase(caseId: caseId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deleteCase(caseId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases#get_case)
     */
    public func getCase(_ caseId: Case.Id, completionHandler: @escaping (Outcome<Case, GetError>) -> Void) {
        api.getCase(caseId: caseId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getCase(caseId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases#get_cases)

     suite is required if the project is not running in single suite mode.
     */
    public func getCases(in project: Project, in suite: Suite? = nil, in section: Section? = nil, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Case], GetError>) -> Void) {
        getCases(inProjectWithId: project.id, inSuiteWithId: suite?.id, inSectionWithId: section?.id, filteredBy: filters, completionHandler: completionHandler)
    }
    
    public func getBulkCases(in project: Project, in suite: Suite? = nil, in section: Section? = nil, with offset: Int, with limit: Int = 250, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<BulkCases, GetError>) -> Void) {
        var filteredBy = [Filter]()
        filteredBy.append(Filter.init(named: "offset", matching: offset))
        filteredBy.append(Filter.init(named: "limit", matching: limit))
        if let filters = filters {
            filteredBy.append(contentsOf: filters)
        }
        getBulkCases(inProjectWithId: project.id, inSuiteWithId: suite?.id, inSectionWithId: section?.id, filteredBy: filteredBy, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases#get_cases)

     suiteId is required if the project is not running in single suite mode.
     */
    public func getCases(inProjectWithId projectId: Project.Id, inSuiteWithId suiteId: Suite.Id? = nil, inSectionWithId sectionId: Section.Id? = nil, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Case], GetError>) -> Void) {
        api.getCases(projectId: projectId, suiteId: suiteId, sectionId: sectionId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getCases(inProjectWithId: projectId, inSuiteWithId: suiteId, inSectionWithId: sectionId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }
    
    public func getBulkCases(inProjectWithId projectId: Project.Id, inSuiteWithId suiteId: Suite.Id? = nil, inSectionWithId sectionId: Section.Id? = nil, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<BulkCases, GetError>) -> Void) {
        api.getCases(projectId: projectId, suiteId: suiteId, sectionId: sectionId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getBulkCases(inProjectWithId: projectId, inSuiteWithId: suiteId, inSectionWithId: sectionId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases#update_case)
     */
    public func updateCase(_ case: Case, completionHandler: @escaping (Outcome<Case, UpdateError>) -> Void) {

        let dataOutcome = self.data(from: `case`)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updateCase(caseId: `case`.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updateCase(`case`, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - CaseField

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases-fields#get_case_fields)
     */
    public func addCaseField<DataType: NewCaseFieldData>(_ newCaseField: NewCaseField<DataType>, completionHandler: @escaping (Outcome<CaseField, AddError>) -> Void) {

        let dataOutcome = self.data(from: newCaseField)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addCaseField(data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addCaseField(newCaseField, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases-fields#get_case_fields)
     */
    public func getCaseFields(completionHandler: @escaping (Outcome<[CaseField], GetError>) -> Void) {
        api.getCaseFields { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getCaseFields(completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - CaseType

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-cases-types#get_case_types)
     */
    public func getCaseTypes(completionHandler: @escaping (Outcome<[CaseType], GetError>) -> Void) {
        api.getCaseTypes { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getCaseTypes(completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Configuration

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#add_config)
     */
    public func addConfiguration(_ newConfiguration: NewConfiguration, to configurationGroup: ConfigurationGroup, completionHandler: @escaping (Outcome<Configuration, AddError>) -> Void) {
        addConfiguration(newConfiguration, toConfigurationGroupWithId: configurationGroup.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#add_config)
     */
    public func addConfiguration(_ newConfiguration: NewConfiguration, toConfigurationGroupWithId configurationGroupId: ConfigurationGroup.Id, completionHandler: @escaping (Outcome<Configuration, AddError>) -> Void) {

        let dataOutcome = self.data(from: newConfiguration)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addConfiguration(configurationGroupId: configurationGroupId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addConfiguration(newConfiguration, toConfigurationGroupWithId: configurationGroupId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#delete_config)
     */
    public func deleteConfiguration(_ configuration: Configuration, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deleteConfiguration(configuration.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#delete_config)
     */
    public func deleteConfiguration(_ configurationId: Configuration.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deleteConfiguration(configurationId: configurationId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deleteConfiguration(configurationId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#update_config)
     */
    public func updateConfiguration(_ configuration: Configuration, completionHandler: @escaping (Outcome<Configuration, UpdateError>) -> Void) {

        let dataOutcome = self.data(from: configuration)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updateConfiguration(configurationId: configuration.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updateConfiguration(configuration, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - ConfigurationGroup

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#add_config_group)
     */
    public func addConfigurationGroup(_ newConfigurationGroup: NewConfigurationGroup, to project: Project, completionHandler: @escaping (Outcome<ConfigurationGroup, AddError>) -> Void) {
        addConfigurationGroup(newConfigurationGroup, toProjectWithId: project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#add_config_group)
     */
    public func addConfigurationGroup(_ newConfigurationGroup: NewConfigurationGroup, toProjectWithId projectId: Project.Id, completionHandler: @escaping (Outcome<ConfigurationGroup, AddError>) -> Void) {

        let dataOutcome = self.data(from: newConfigurationGroup)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addConfigurationGroup(projectId: projectId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addConfigurationGroup(newConfigurationGroup, toProjectWithId: projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#delete_config_group)
     */
    public func deleteConfigurationGroup(_ configurationGroup: ConfigurationGroup, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deleteConfigurationGroup(configurationGroup.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#delete_config_group)
     */
    public func deleteConfigurationGroup(_ configurationGroupId: ConfigurationGroup.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deleteConfigurationGroup(configurationGroupId: configurationGroupId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deleteConfigurationGroup(configurationGroupId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     Gets all ConfigurationGroups from all Projects.

     - Returns a de-duped array of 0+ ConfigurationGroups from all Projects upon
       success.
     - Returns an ErrorContainer of 1+ errors if any of the GET requests failed.

     This method makes multiple async API calls across all accessible projects
     to gather all ConfigurationGroups. It may be expensive/slow to run if you
     have many projects.
     */
    public func getConfigurationGroups(completionHandler: @escaping (Outcome<[ConfigurationGroup], ErrorContainer<GetError>>) -> Void) {

        getProjects { [weak self] (projectsOutcome) in

            switch projectsOutcome {
            case .failure(let error):
                completionHandler(.failure(ErrorContainer(error)))
            case .success(let projects):

                let projectIds = Set(projects.compactMap({ $0.id }))
                self?.getConfigurationGroups(inProjectsWithIds: projectIds) { (configurationGroupsOutcomes) in

                    let outcomes = configurationGroupsOutcomes.compactMap { $1 } // Discard projectId keys.
                    var allConfigurationGroups = [ConfigurationGroup]()
                    var allErrors = [GetError]()

                    // Extract all ConfigurationGroups/errors from outcomes.
                    for outcome in outcomes {
                        switch outcome {
                        case .failure(let error):
                            allErrors.append(error)
                        case .success(let configurationGroups):
                            for configurationGroup in configurationGroups {
                                guard allConfigurationGroups.filter({ $0.id == configurationGroup.id }).count == 0 else { // Skip duplicates.
                                    continue
                                }
                                allConfigurationGroups.append(configurationGroup)
                            }
                        }
                    }

                    if let errorContainer = ErrorContainer(allErrors) {
                        completionHandler(.failure(errorContainer)) // Fail if there are any errors.
                    } else {
                        completionHandler(.success(allConfigurationGroups))
                    }
                }
            }
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#get_configs)
     */
    public func getConfigurationGroups(in project: Project, completionHandler: @escaping (Outcome<[ConfigurationGroup], GetError>) -> Void) {
        getConfigurationGroups(inProjectWithId: project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#get_configs)
     */
    public func getConfigurationGroups(inProjectWithId projectId: Project.Id, completionHandler: @escaping (Outcome<[ConfigurationGroup], GetError>) -> Void) {
        api.getConfigurations(projectId: projectId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getConfigurationGroups(inProjectWithId: projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-configs#update_config_group)
     */
    public func updateConfigurationGroup(_ configurationGroup: ConfigurationGroup, completionHandler: @escaping (Outcome<ConfigurationGroup, UpdateError>) -> Void) {

        let dataOutcome = self.data(from: configurationGroup)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updateConfigurationGroup(configurationGroupId: configurationGroup.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updateConfigurationGroup(configurationGroup, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Milestone

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-milestones#add_milestone)
     */
    public func addMilestone(_ newMilestone: NewMilestone, to project: Project, completionHandler: @escaping (Outcome<Milestone, AddError>) -> Void) {
        addMilestone(newMilestone, toProjectWithId: project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-milestones#add_milestone)
     */
    public func addMilestone(_ newMilestone: NewMilestone, toProjectWithId projectId: Project.Id, completionHandler: @escaping (Outcome<Milestone, AddError>) -> Void) {

        let dataOutcome = self.data(from: newMilestone)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addMilestone(projectId: projectId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addMilestone(newMilestone, toProjectWithId: projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-milestones#delete_milestone)
     */
    public func deleteMilestone(_ milestone: Milestone, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deleteMilestone(milestone.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-milestones#delete_milestone)
     */
    public func deleteMilestone(_ milestoneId: Milestone.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deleteMilestone(milestoneId: milestoneId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deleteMilestone(milestoneId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-milestones#get_milestone)
     */
    public func getMilestone(_ milestoneId: Milestone.Id, completionHandler: @escaping (Outcome<Milestone, GetError>) -> Void) {
        api.getMilestone(milestoneId: milestoneId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getMilestone(milestoneId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-milestones#get_milestones)

     NOTE: This API call does not include .milestones for the Milestone's. For
     that behavior use getMilestone(...).
     */
    public func getMilestones(in project: Project, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Milestone], GetError>) -> Void) {
        getMilestones(inProjectWithId: project.id, filteredBy: filters, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-milestones#get_milestones)

     NOTE: This API call does not include .milestones for the Milestone's. For
     that behavior use getMilestone(...).
     */
    public func getMilestones(inProjectWithId projectId: Project.Id, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Milestone], GetError>) -> Void) {
        api.getMilestones(projectId: projectId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getMilestones(inProjectWithId: projectId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-milestones#update_milestone)
     */
    public func updateMilestone(_ milestone: Milestone, completionHandler: @escaping (Outcome<Milestone, UpdateError>) -> Void) {

        let dataOutcome = self.data(from: milestone)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updateMilestone(milestoneId: milestone.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updateMilestone(milestone, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Plan

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#add_plan)
     */
    public func addPlan(_ newPlan: NewPlan, to project: Project, completionHandler: @escaping (Outcome<Plan, AddError>) -> Void) {
        addPlan(newPlan, toProjectWithId: project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#add_plan)
     */
    public func addPlan(_ newPlan: NewPlan, toProjectWithId projectId: Project.Id, completionHandler: @escaping (Outcome<Plan, AddError>) -> Void) {

        let dataOutcome = self.data(from: newPlan)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addPlan(projectId: projectId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addPlan(newPlan, toProjectWithId: projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#close_plan)
     */
    public func closePlan(_ plan: Plan, completionHandler: @escaping (Outcome<Plan, CloseError>) -> Void) {
        closePlan(plan.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#close_plan)
     */
    public func closePlan(_ planId: Plan.Id, completionHandler: @escaping (Outcome<Plan, CloseError>) -> Void) {
        api.closePlan(planId: planId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.closePlan(planId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#delete_plan)
     */
    public func deletePlan(_ plan: Plan, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deletePlan(plan.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#delete_plan)
     */
    public func deletePlan(_ planId: Plan.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deletePlan(planId: planId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deletePlan(planId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#get_plan)
     */
    public func getPlan(_ planId: Plan.Id, completionHandler: @escaping (Outcome<Plan, GetError>) -> Void) {
        api.getPlan(planId: planId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getPlan(planId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#get_plans)

     This API call does not include .entries for the Plan's. For that behavior
     use getPlan(...).
     */
    public func getPlans(in project: Project, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Plan], GetError>) -> Void) {
        getPlans(inProjectWithId: project.id, filteredBy: filters, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#get_plans)

     This API call does not include .entries for the Plan's. For that behavior
     use getPlan(...).
     */
    public func getPlans(inProjectWithId projectId: Project.Id, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Plan], GetError>) -> Void) {
        api.getPlans(projectId: projectId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getPlans(inProjectWithId: projectId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#update_plan)
     */
    public func updatePlan(_ plan: Plan, completionHandler: @escaping (Outcome<Plan, UpdateError>) -> Void) {

        let dataOutcome = self.data(from: plan)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updatePlan(planId: plan.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updatePlan(plan, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Plan.Entry

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#add_plan_entry)

     Upon success only the newly added run(s) are included in Plan.Entry.runs.
     Any other runs are not included. To get all runs call getPlan() after this
     method completes successfully.

     Upon success `plan`.entries will be stale; use getPlan() to get a fresh
     Plan.
     */
    public func addPlanEntry(_ newPlanEntry: NewPlan.Entry, to plan: Plan, completionHandler: @escaping (Outcome<Plan.Entry, AddError>) -> Void) {
        addPlanEntry(newPlanEntry, toPlanWithId: plan.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#add_plan_entry)

     Upon success only the newly added run(s) are included in Plan.Entry.runs.
     Any other runs are not included. To get all runs call getPlan() after this
     method completes successfully.

     Upon success Plan.entries for `planId` will be stale; use getPlan() to get
     a fresh Plan.
     */
    public func addPlanEntry(_ newPlanEntry: NewPlan.Entry, toPlanWithId planId: Plan.Id, completionHandler: @escaping (Outcome<Plan.Entry, AddError>) -> Void) {

        let dataOutcome = self.data(from: newPlanEntry)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addPlanEntry(planId: planId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addPlanEntry(newPlanEntry, toPlanWithId: planId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#delete_plan_entry)

     Upon success `plan`.entries will be stale; use getPlan() to get a fresh
     Plan.
     */
    public func deletePlanEntry(_ planEntry: Plan.Entry, from plan: Plan, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deletePlanEntry(planEntry.id, fromPlanWithId: plan.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#delete_plan_entry)

     Upon success Plan.entries for `planId` will be stale; use getPlan() to get
     a fresh Plan.
     */
    public func deletePlanEntry(_ planEntryId: Plan.Entry.Id, fromPlanWithId planId: Plan.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deletePlanEntry(planId: planId, planEntryId: planEntryId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deletePlanEntry(planEntryId, fromPlanWithId: planId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#update_plan_entry)

     Upon success this returns a new Plan.Entry including all of its test Run's.
     `plan`.entries will be stale; use getPlan() to get a fresh Plan.

     Plan.Entry updates differ slightly from other API updates. You can:

     - Update variable properties affecting the Plan.Entry itself.
     - Pass `planEntryRunsData` affecting all Plan.Entry.runs in bulk.
     */
    public func updatePlanEntry(_ planEntry: Plan.Entry, in plan: Plan, with planEntryRuns: UpdatePlanEntryRuns? = nil, completionHandler: @escaping (Outcome<Plan.Entry, UpdateError>) -> Void) {
        updatePlanEntry(planEntry, inPlanWithId: plan.id, with: planEntryRuns, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-plans#update_plan_entry)

     Upon success this returns a new Plan.Entry including all of its test Run's.
     Plan.entries for `planId` will be stale; use getPlan() to get a fresh Plan.

     Plan.Entry updates differ slightly from other API updates. You can:

     - Update variable properties affecting the Plan.Entry itself.
     - Pass `planEntryRunsData` affecting all Plan.Entry.runs in bulk.
     */
    public func updatePlanEntry(_ planEntry: Plan.Entry, inPlanWithId planId: Plan.Id, with planEntryRuns: UpdatePlanEntryRuns? = nil, completionHandler: @escaping (Outcome<Plan.Entry, UpdateError>) -> Void) {

        let dataOutcome: DataOutcome
        if let planEntryRuns = planEntryRuns {
            dataOutcome = self.data(from: [planEntry, planEntryRuns])
        } else {
            dataOutcome = self.data(from: planEntry)
        }

        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updatePlanEntry(planId: planId, planEntryId: planEntry.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updatePlanEntry(planEntry, inPlanWithId: planId, with: planEntryRuns, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Priority

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-priorities#get_priorities)
     */
    public func getPriorities(completionHandler: @escaping (Outcome<[Priority], GetError>) -> Void) {
        api.getPriorities { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getPriorities(completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Project

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-projects#add_project)
     */
    public func addProject(_ newProject: NewProject, completionHandler: @escaping (Outcome<Project, AddError>) -> Void) {

        let dataOutcome = self.data(from: newProject)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addProject(data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addProject(newProject, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-projects#delete_project)
     */
    public func deleteProject(_ project: Project, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deleteProject(project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-projects#delete_project)
     */
    public func deleteProject(_ projectId: Project.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deleteProject(projectId: projectId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deleteProject(projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-projects#get_project)

     You must have at least Read-only access to the project otherwise a 403
     error will be returned.
     */
    public func getProject(_ projectId: Project.Id, completionHandler: @escaping (Outcome<Project, GetError>) -> Void) {
        api.getProject(projectId: projectId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getProject(projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-projects#get_projects)

     Returns all projects which you have at least Read-only access to. All other
     projects will be silently omitted.

     To determine if you have at least Read-only access to a project use
     getProject() instead. It will return an explicit error if you do not have
     access to a project.
     */
    public func getProjects(filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Project], GetError>) -> Void) {
        api.getProjects(filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getProjects(filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-projects#update_project)
     */
    public func updateProject(_ project: Project, completionHandler: @escaping (Outcome<Project, UpdateError>) -> Void) {

        let dataOutcome = self.data(from: project)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updateProject(projectId: project.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updateProject(project, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Result

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#add_result)
     */
    public func addResult(_ newResult: NewResult, to test: Test, completionHandler: @escaping (Outcome<Result, AddError>) -> Void) {
        addResult(newResult, toTestWithId: test.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#add_result)
     */
    public func addResult(_ newResult: NewResult, toTestWithId testId: Test.Id, completionHandler: @escaping (Outcome<Result, AddError>) -> Void) {

        let dataOutcome = self.data(from: newResult)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addResult(testId: testId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addResult(newResult, toTestWithId: testId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#add_result_for_case)
     */
    public func addResultForCase(_ newResult: NewResult, to run: Run, to case: Case, completionHandler: @escaping (Outcome<Result, AddError>) -> Void) {
        addResultForCase(newResult, toRunWithId: run.id, toCaseWithId: `case`.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#add_result_for_case)
     */
    public func addResultForCase(_ newResult: NewResult, toRunWithId runId: Run.Id, toCaseWithId caseId: Case.Id, completionHandler: @escaping (Outcome<Result, AddError>) -> Void) {

        let dataOutcome = self.data(from: newResult)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addResultForCase(runId: runId, caseId: caseId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addResultForCase(newResult, toRunWithId: runId, toCaseWithId: caseId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#add_results)
     */
    public func addResults(_ newTestResults: NewTestResults, to run: Run, completionHandler: @escaping (Outcome<[Result], AddError>) -> Void) {
        addResults(newTestResults, toRunWithId: run.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#add_results)
     */
    public func addResults(_ newTestResults: NewTestResults, toRunWithId runId: Run.Id, completionHandler: @escaping (Outcome<[Result], AddError>) -> Void) {

        let dataOutcome = self.data(from: newTestResults)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addResults(runId: runId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addResults(newTestResults, toRunWithId: runId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#add_results_for_cases)
     */
    public func addResultsForCases(_ newCaseResults: NewCaseResults, to run: Run, completionHandler: @escaping (Outcome<[Result], AddError>) -> Void) {
        addResultsForCases(newCaseResults, toRunWithId: run.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#add_results_for_cases)
     */
    public func addResultsForCases(_ newCaseResults: NewCaseResults, toRunWithId runId: Run.Id, completionHandler: @escaping (Outcome<[Result], AddError>) -> Void) {

        let dataOutcome = self.data(from: newCaseResults)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addResultsForCases(runId: runId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addResultsForCases(newCaseResults, toRunWithId: runId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#get_results)
     */
    public func getResultsForTest(_ test: Test, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Result], GetError>) -> Void) {
        getResultsForTest(test.id, filteredBy: filters, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#get_results)
     */
    public func getResultsForTest(_ testId: Test.Id, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Result], GetError>) -> Void) {
        api.getResults(testId: testId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getResultsForTest(testId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#get_results_for_case)
     */
    public func getResultsForCase(_ case: Case, in run: Run, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Result], GetError>) -> Void) {
        getResultsForCase(`case`.id, inRunWithId: run.id, filteredBy: filters, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#get_results_for_case)
     */
    public func getResultsForCase(_ caseId: Case.Id, inRunWithId runId: Run.Id, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Result], GetError>) -> Void) {
        api.getResultsForCase(runId: runId, caseId: caseId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getResultsForCase(caseId, inRunWithId: runId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#get_results_for_run)
     */
    public func getResultsForRun(_ run: Run, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Result], GetError>) -> Void) {
        getResultsForRun(run.id, filteredBy: filters, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results#get_results_for_run)
     */
    public func getResultsForRun(_ runId: Run.Id, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Result], GetError>) -> Void) {
        api.getResultsForRun(runId: runId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getResultsForRun(runId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - ResultField

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-results-fields#get_result_fields)
     */
    public func getResultFields(completionHandler: @escaping (Outcome<[ResultField], GetError>) -> Void) {
        api.getResultFields { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getResultFields(completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Run

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#add_run)
     */
    public func addRun(_ newRun: NewRun, to project: Project, completionHandler: @escaping (Outcome<Run, AddError>) -> Void) {
        addRun(newRun, toProjectWithId: project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#add_run)
     */
    public func addRun(_ newRun: NewRun, toProjectWithId projectId: Project.Id, completionHandler: @escaping (Outcome<Run, AddError>) -> Void) {

        let dataOutcome = self.data(from: newRun)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addRun(projectId: projectId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addRun(newRun, toProjectWithId: projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#close_run)
     */
    public func closeRun(_ run: Run, completionHandler: @escaping (Outcome<Run, CloseError>) -> Void) {
        closeRun(run.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#close_run)
     */
    public func closeRun(_ runId: Run.Id, completionHandler: @escaping (Outcome<Run, CloseError>) -> Void) {
        api.closeRun(runId: runId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.closeRun(runId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#delete_run)
     */
    public func deleteRun(_ run: Run, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deleteRun(run.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#delete_run)
     */
    public func deleteRun(_ runId: Run.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deleteRun(runId: runId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deleteRun(runId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#get_run)
     */
    public func getRun(_ runId: Run.Id, completionHandler: @escaping (Outcome<Run, GetError>) -> Void) {
        api.getRun(runId: runId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getRun(runId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#get_runs)

     This only returns Runs which are not part of a Plan.
     */
    public func getRuns(in project: Project, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Run], GetError>) -> Void) {
        getRuns(inProjectWithId: project.id, filteredBy: filters, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#get_runs)

     This only returns Runs which are not part of a Plan.
     */
    public func getRuns(inProjectWithId projectId: Project.Id, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Run], GetError>) -> Void) {
        api.getRuns(projectId: projectId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getRuns(inProjectWithId: projectId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-runs#update_run)
     */
    public func updateRun(_ run: Run, completionHandler: @escaping (Outcome<Run, UpdateError>) -> Void) {

        let dataOutcome = self.data(from: run)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updateRun(runId: run.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updateRun(run, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Section

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-sections#add_section)
     */
    public func addSection(_ newSection: NewSection, to project: Project, completionHandler: @escaping (Outcome<Section, AddError>) -> Void) {
        addSection(newSection, toProjectWithId: project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-sections#add_section)
     */
    public func addSection(_ newSection: NewSection, toProjectWithId projectId: Project.Id, completionHandler: @escaping (Outcome<Section, AddError>) -> Void) {

        let dataOutcome = self.data(from: newSection)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addSection(projectId: projectId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addSection(newSection, toProjectWithId: projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-sections#delete_section)
     */
    public func deleteSection(_ section: Section, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deleteSection(section.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-sections#delete_section)
     */
    public func deleteSection(_ sectionId: Section.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deleteSection(sectionId: sectionId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deleteSection(sectionId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-sections#get_section)
     */
    public func getSection(_ sectionId: Section.Id, completionHandler: @escaping (Outcome<Section, GetError>) -> Void) {
        api.getSection(sectionId: sectionId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getSection(sectionId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-sections#get_sections)
     */
    public func getSections(in project: Project, in suite: Suite? = nil, completionHandler: @escaping (Outcome<[Section], GetError>) -> Void) {
        getSections(inProjectWithId: project.id, inSuiteWithId: suite?.id, completionHandler: completionHandler)
    }
    
    public func getBulkSections(in project: Project, in suite: Suite? = nil, with offset: Int, with limit: Int = 250, completionHandler: @escaping (Outcome<BulkSections, GetError>) -> Void) {
        getBulkSections(inProjectWithId: project.id, inSuiteWithId: suite?.id, filteredBy: [Filter.init(named: "offset", matching: offset), Filter.init(named: "limit", matching: limit)], completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-sections#get_sections)
     */
    public func getSections(inProjectWithId projectId: Project.Id, inSuiteWithId suiteId: Suite.Id? = nil, completionHandler: @escaping (Outcome<[Section], GetError>) -> Void) {
        api.getSections(projectId: projectId, suiteId: suiteId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getSections(inProjectWithId: projectId, inSuiteWithId: suiteId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }
    
    public func getBulkSections(inProjectWithId projectId: Project.Id, inSuiteWithId suiteId: Suite.Id? = nil, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<BulkSections, GetError>) -> Void) {
        api.getSections(projectId: projectId, suiteId: suiteId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getBulkSections(inProjectWithId: projectId, inSuiteWithId: suiteId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-sections#update_section)
     */
    public func updateSection(_ section: Section, completionHandler: @escaping (Outcome<Section, UpdateError>) -> Void) {

        let dataOutcome = self.data(from: section)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updateSection(sectionId: section.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updateSection(section, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Status

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-statuses#get_statuses)
     */
    public func getStatuses(completionHandler: @escaping (Outcome<[Status], GetError>) -> Void) {
        api.getStatuses { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getStatuses(completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Suite

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-suites#add_suite)
     */
    public func addSuite(_ newSuite: NewSuite, to project: Project, completionHandler: @escaping (Outcome<Suite, AddError>) -> Void) {
        addSuite(newSuite, toProjectWithId: project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-suites#add_suite)
     */
    public func addSuite(_ newSuite: NewSuite, toProjectWithId projectId: Project.Id, completionHandler: @escaping (Outcome<Suite, AddError>) -> Void) {

        let dataOutcome = self.data(from: newSuite)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.addSuite(projectId: projectId, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.addSuite(newSuite, toProjectWithId: projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-suites#delete_suite)
     */
    public func deleteSuite(_ suite: Suite, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        deleteSuite(suite.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-suites#delete_suite)
     */
    public func deleteSuite(_ suiteId: Suite.Id, completionHandler: @escaping (Outcome<Void?, DeleteError>) -> Void) {
        api.deleteSuite(suiteId: suiteId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.deleteSuite(suiteId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                switch processedOutcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(_):
                    completionHandler(.success(nil))
                }
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-suites#get_suite)
     */
    public func getSuite(_ suiteId: Suite.Id, completionHandler: @escaping (Outcome<Suite, GetError>) -> Void) {
        api.getSuite(suiteId: suiteId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getSuite(suiteId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-suites#get_suites)
     */
    public func getSuites(in project: Project, completionHandler: @escaping (Outcome<[Suite], GetError>) -> Void) {
        getSuites(inProjectWithId: project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-suites#get_suites)
     */
    public func getSuites(inProjectWithId projectId: Project.Id, completionHandler: @escaping (Outcome<[Suite], GetError>) -> Void) {
        api.getSuites(projectId: projectId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getSuites(inProjectWithId: projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-suites#update_suite)
     */
    public func updateSuite(_ suite: Suite, completionHandler: @escaping (Outcome<Suite, UpdateError>) -> Void) {

        let dataOutcome = self.data(from: suite)
        let data: Data
        switch dataOutcome {
        case .failure(let error):
            completionHandler(.failure(.objectConversionError(error)))
            return
        case .success(let aData):
            data = aData
        }

        api.updateSuite(suiteId: suite.id, data: data) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.updateSuite(suite, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Template

    /**
     Gets all Templates from all Projects. A template may appear in some or all
     projects.

     - Returns a de-duped array of 0+ Templates from all Projects upon success.
     - Returns an ErrorContainer of 1+ errors if any of the GET requests failed.

     This method makes multiple async API calls across all accessible projects
     to gather all templates. It may be expensive/slow to run if you have many
     projects.
     */
    public func getTemplates(completionHandler: @escaping (Outcome<[Template], ErrorContainer<GetError>>) -> Void) {

        getProjects { [weak self] (projectsOutcome) in

            switch projectsOutcome {
            case .failure(let error):
                completionHandler(.failure(ErrorContainer(error)))
            case .success(let projects):

                let projectIds = Set(projects.compactMap({ $0.id }))
                self?.getTemplates(inProjectsWithIds: projectIds) { (templatesOutcomes) in

                    let outcomes = templatesOutcomes.compactMap { $1 } // Discard projectId keys.
                    var allTemplates = [Template]()
                    var allErrors = [GetError]()

                    // Extract all templates/errors from outcomes.
                    for outcome in outcomes {
                        switch outcome {
                        case .failure(let error):
                            allErrors.append(error)
                        case .success(let templates):
                            for template in templates {
                                guard allTemplates.filter({ $0.id == template.id }).count == 0 else { // Skip duplicates.
                                    continue
                                }
                                allTemplates.append(template)
                            }
                        }
                    }

                    if let errorContainer = ErrorContainer(allErrors) {
                        completionHandler(.failure(errorContainer)) // Fail if there are any errors.
                    } else {
                        completionHandler(.success(allTemplates))
                    }
                }
            }
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-templates#get_templates)
     */
    public func getTemplates(in project: Project, completionHandler: @escaping (Outcome<[Template], GetError>) -> Void) {
        getTemplates(inProjectWithId: project.id, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-templates#get_templates)
     */
    public func getTemplates(inProjectWithId projectId: Project.Id, completionHandler: @escaping (Outcome<[Template], GetError>) -> Void) {
        api.getTemplates(projectId: projectId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getTemplates(inProjectWithId: projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - Test

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-tests#get_test)
     */
    public func getTest(_ testId: Test.Id, completionHandler: @escaping (Outcome<Test, GetError>) -> Void) {
        api.getTest(testId: testId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getTest(testId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-tests#get_tests)
     */
    public func getTests(in run: Run, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Test], GetError>) -> Void) {
        getTests(inRunWithId: run.id, filteredBy: filters, completionHandler: completionHandler)
    }
    
    public func getBulkTests(in run: Run, with offset: Int, with limit: Int = 250, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<BulkTests, GetError>) -> Void) {
        var filteredBy = [Filter]()
        filteredBy.append(Filter.init(named: "offset", matching: offset))
        filteredBy.append(Filter.init(named: "limit", matching: limit))
        if let filters = filters {
            filteredBy.append(contentsOf: filters)
        }
        getBulkTests(inRunWithId: run.id, filteredBy: filteredBy, completionHandler: completionHandler)
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-tests#get_tests)
     */
    public func getTests(inRunWithId runId: Run.Id, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<[Test], GetError>) -> Void) {
        api.getTests(runId: runId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getTests(inRunWithId: runId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }
    
    public func getBulkTests(inRunWithId runId: Run.Id, filteredBy filters: [Filter]? = nil, completionHandler: @escaping (Outcome<BulkTests, GetError>) -> Void) {
        api.getTests(runId: runId, filters: filters) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getBulkTests(inRunWithId: runId, filteredBy: filters, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    // MARK: - User

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-users#get_user)
     */
    public func getUser(_ userId: User.Id, completionHandler: @escaping (Outcome<User, GetError>) -> Void) {
        api.getUser(userId: userId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getUser(userId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-users#get_user_by_email)
     */
    public func getUserByEmail(_ email: String, completionHandler: @escaping (Outcome<User, GetError>) -> Void) {
        api.getUserByEmail(email) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getUserByEmail(email, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

    /**
     [API Reference](http://docs.gurock.com/testrail-api2/reference-users#get_users)
     */
    public func getUsers(_ projectId: Int, completionHandler: @escaping (Outcome<[User], GetError>) -> Void) {
        api.getUsers(projectId) { [weak self] (apiRequestOutcome) in
            self?.process(apiRequestOutcome, retryHandler: {
                self?.getUsers(projectId, completionHandler: completionHandler)
            }, completionHandler: { (processedOutcome) in
                completionHandler(processedOutcome)
            })
        }
    }

}

// MARK: - Objects (Fileprivate Matching)

extension ObjectAPI {

    /**
     - Upon success returns an Outcome with items from |items| matching all
       |ids|. Requires every id in |ids| to match an item.
     - Upon failure returns an Outcome indicating if no matches were found, or
       if only partial matches were found.
     */
    fileprivate static func matches<Item: Identifiable>(from items: [Item], matchingIds ids: Set<Item.Id>) -> Outcome<[Item], MultipleMatchError<Item, Item.Id>> {

        // Find all matches.
        var matches = [Item]()
        var missing = Set<Item.Id>()

        for id in ids {
            guard let item = items.filter({ $0.id == id }).first else {
                missing.insert(id)
                continue
            }
            guard matches.contains(where: { $0.id == item.id }) == false else {
                continue
            }
            matches.append(item)
        }

        // Were all matches found?
        guard missing.count == 0 else {
            if matches.count == 0 {
                return .failure(.noMatchesFound(missing: missing))
            } else {
                return .failure(.partialMatchesFound(matches: matches, missing: missing))
            }
        }

        // All matches found.
        return .success(matches)
    }

}

// MARK: - Objects (Matching)

extension ObjectAPI {

    // MARK: - CaseType

    public func getCaseType(matching id: CaseType.Id, completionHandler: @escaping (Outcome<CaseType, MatchError<SingleMatchError<CaseType.Id>, GetError>>) -> Void) {
        getCaseTypes { (outcome) in
            switch outcome {
            case .failure(let error):
                completionHandler(.failure(.otherError(error)))
            case .success(let caseTypes):
                if let caseType = caseTypes.filter({ $0.id == id }).first {
                    completionHandler(.success(caseType))
                } else {
                    completionHandler(.failure(.matchError(.noMatchFound(missing: id))))
                }
            }
        }
    }

    // MARK: - ConfigurationGroup

    public func getConfigurationGroup(matching id: ConfigurationGroup.Id, completionHandler: @escaping (Outcome<ConfigurationGroup, MatchError<SingleMatchError<ConfigurationGroup.Id>, ErrorContainer<GetError>>>) -> Void) {
        getConfigurationGroups { (outcome) in
            switch outcome {
            case .failure(let error):
                completionHandler(.failure(.otherError(error)))
            case .success(let configurationGroups):
                if let configurationGroup = configurationGroups.filter({ $0.id == id }).first {
                    completionHandler(.success(configurationGroup))
                } else {
                    completionHandler(.failure(.matchError(.noMatchFound(missing: id))))
                }
            }
        }
    }

    // MARK: - Priority

    public func getPriority(matching id: Priority.Id, completionHandler: @escaping (Outcome<Priority, MatchError<SingleMatchError<Priority.Id>, GetError>>) -> Void) {
        getPriorities { (outcome) in
            switch outcome {
            case .failure(let error):
                completionHandler(.failure(.otherError(error)))
            case .success(let priorities):
                if let priority = priorities.filter({ $0.id == id }).first {
                    completionHandler(.success(priority))
                } else {
                    completionHandler(.failure(.matchError(.noMatchFound(missing: id))))
                }
            }
        }
    }

    // MARK: - Status

    public func getStatus(matching id: Status.Id, completionHandler: @escaping (Outcome<Status, MatchError<SingleMatchError<Status.Id>, GetError>>) -> Void) {
        getStatuses { (outcome) in
            switch outcome {
            case .failure(let error):
                completionHandler(.failure(.otherError(error)))
            case .success(let statuses):
                if let status = statuses.filter({ $0.id == id }).first {
                    completionHandler(.success(status))
                } else {
                    completionHandler(.failure(.matchError(.noMatchFound(missing: id))))
                }
            }
        }
    }

    // MARK: - Template

    public func getTemplate(matching id: Template.Id, completionHandler: @escaping (Outcome<Template, MatchError<SingleMatchError<Template.Id>, ErrorContainer<GetError>>>) -> Void) {
        getTemplates { (outcome) in
            switch outcome {
            case .failure(let errors):
                completionHandler(.failure(.otherError(errors)))
            case .success(let templates):
                if let template = templates.filter({ $0.id == id }).first {
                    completionHandler(.success(template))
                } else {
                    completionHandler(.failure(.matchError(.noMatchFound(missing: id))))
                }
            }
        }
    }

    public func getTemplates(matching ids: [Template.Id], completionHandler: @escaping (Outcome<[Template], MatchError<MultipleMatchError<Template, Template.Id>, ErrorContainer<GetError>>>) -> Void) {
        getTemplates(matching: Set(ids), completionHandler: completionHandler) // De-dupe ids
    }

    private func getTemplates(matching ids: Set<Template.Id>, completionHandler: @escaping (Outcome<[Template], MatchError<MultipleMatchError<Template, Template.Id>, ErrorContainer<GetError>>>) -> Void) {
        getTemplates { (outcome) in
            switch outcome {
            case .failure(let errors):
                completionHandler(.failure(.otherError(errors)))
            case .success(let templates):
                let matchesOutcome = ObjectAPI.matches(from: templates, matchingIds: ids)
                switch matchesOutcome {
                case .failure(let error):
                    completionHandler(.failure(.matchError(error)))
                case .success(let matches):
                    completionHandler(.success(matches))
                }
            }
        }
    }

}

// MARK: - Objects (Forward Relationships)

extension ObjectAPI {

    // MARK: - Case

    public func createdBy(_ `case`: Case, completionHandler: @escaping (Outcome<User, GetError>) -> Void) {
        getUser(`case`.createdBy, completionHandler: completionHandler)
    }

    public func milestone(_ `case`: Case, completionHandler: @escaping (Outcome<Milestone?, GetError>) -> Void) {
        milestone(`case`.milestoneId, completionHandler: completionHandler)
    }

    public func priority(_ `case`: Case, completionHandler: @escaping (Outcome<Priority, MatchError<SingleMatchError<Case.Id>, GetError>>) -> Void) {
        getPriority(matching: `case`.priorityId, completionHandler: completionHandler)
    }

    public func section(_ `case`: Case, completionHandler: @escaping (Outcome<Section?, GetError>) -> Void) {
        section(`case`.sectionId, completionHandler: completionHandler)
    }

    public func suite(_ `case`: Case, completionHandler: @escaping (Outcome<Suite?, GetError>) -> Void) {
        suite(`case`.suiteId, completionHandler: completionHandler)
    }

    public func template(_ `case`: Case, completionHandler: @escaping (Outcome<Template, MatchError<SingleMatchError<Case.Id>, ErrorContainer<GetError>>>) -> Void) {
        getTemplate(matching: `case`.templateId, completionHandler: completionHandler)
    }

    public func type(_ `case`: Case, completionHandler: @escaping (Outcome<CaseType, MatchError<SingleMatchError<Case.Id>, GetError>>) -> Void) {
        getCaseType(matching: `case`.typeId, completionHandler: completionHandler)
    }

    public func updatedBy(_ `case`: Case, completionHandler: @escaping (Outcome<User, GetError>) -> Void) {
        getUser(`case`.updatedBy, completionHandler: completionHandler)
    }

    // MARK: - CaseField

    public func templates(_ caseField: CaseField, completionHandler: @escaping (Outcome<[Template], MatchError<MultipleMatchError<Template, Template.Id>, ErrorContainer<GetError>>>) -> Void) {
        getTemplates(matching: caseField.templateIds, completionHandler: completionHandler)
    }

    // MARK: - Config

    /**
     Calls the projects() method handling/stripping the MultipleMatchError. Upon
     success this effectively returns all projects accessible to the current API
     user while silently omitting any which are missing. Failure only occurs if
     one or more GetError's occurred.
     */
    public func accessibleProjects(_ config: Config, completionHandler: @escaping(Outcome<[Project]?, ErrorContainer<GetError>>) -> Void) {
        projects(config) { (outcome) in
            switch outcome {
            case .failure(let error):
                switch error {
                case .matchError(let matchError):
                    switch matchError {
                    case .noMatchesFound(_):
                        completionHandler(.success([]))
                    case .partialMatchesFound(let matches, _):
                        completionHandler(.success(matches))
                    }
                case .otherError(let errorContainer):
                    completionHandler(.failure(errorContainer))
                }
            case .success(let projects):
                completionHandler(.success(projects))
            }
        }
    }

    /**
     Asynchronously gets and returns projects for a Config. The outcome passed
     to the completionHandler varies based on:

     1. The value of Config.projectIds.
     2. The authorization level of api.username for each project.

     api.username can read projects it has Read-only or higher access to.
     Project access can be limited to some or all users. This limitation makes
     it impossible for this method to guarentee all projects will be returned
     for a Config. Possible scenarios for Config.projectIds values:

     - .none always passes .success(nil) to the handler.
     - .all passes .success(projects) to the handler upon success. This
        includes all projects the user has access to while silently omitting any
        they do not. .failure(errorContainer) will be passed if there were any
        errors.
     - .some is the same as .all except it will fail if any specified projectIds
       return a 403 error.

     ---------------------------------------------------------------------------

     If .some returns a MultipleMatchError you can potentially recover from it.
     This indicates all projectIds were valid but some/all returned 403 errors.
     To recover:

     1. Change the user used by the API to one which has access to some/all of
        the inaccessible projectIds.
     2. Re-call this command again.
     3. Merge and de-duplicate results.
     4. Repeat until all projects have been received for projectIds.

     If any project has "No Access" set to all users it will not be possible for
     any user to read it without changing its access level.
     */
    // swiftlint:disable:next cyclomatic_complexity
    public func projects(_ config: Config, completionHandler: @escaping(Outcome<[Project]?, MatchError<MultipleMatchError<Project, Project.Id>, ErrorContainer<GetError>>>) -> Void) {
        switch config.projects {
        case .none:
            completionHandler(.success(nil))
        case .all:
            getProjects { (outcome) in
                switch outcome {
                case .failure(let error):
                    completionHandler(.failure(.otherError(ErrorContainer(error))))
                case .success(let projects):
                    completionHandler(.success(projects))
                }
            }
        case .some(let projectIds):
            getProjects(projectIds) { (outcomes) in

                var projects = [Project]()
                var inaccessibleProjectIds = Set<Project.Id>()
                var non403Errors = [GetError]()

                for (projectId, outcome) in outcomes {
                    switch outcome {
                    case .failure(let getError):
                        if case let .statusCodeError(.clientError(clientError)) = getError, clientError.statusCode == 403 {
                            inaccessibleProjectIds.insert(projectId) // 403 errors.
                        } else {
                            non403Errors.append(getError)
                        }
                    case .success(let project):
                        projects.append(project)
                    }
                }

                // Fail if there are any non-403 errors.
                if let errorContainer = ErrorContainer(non403Errors) {
                    completionHandler(.failure(.otherError(errorContainer)))
                    return
                }

                // If some/all of the projectIds were 403 return any matches and
                // all missing.
                guard inaccessibleProjectIds.count == 0 else {
                    if projects.count == 0 {
                        completionHandler(.failure(.matchError(.noMatchesFound(missing: inaccessibleProjectIds))))
                    } else {
                        completionHandler(.failure(.matchError(.partialMatchesFound(matches: projects, missing: inaccessibleProjectIds))))
                    }
                    return
                }

                // All projectIds were found.
                completionHandler(.success(projects))
            }
        }
    }

    // MARK: - Configuration

    public func configurationGroup(_ configuration: Configuration, completionHandler: @escaping (Outcome<ConfigurationGroup, MatchError<SingleMatchError<Configuration.Id>, ErrorContainer<GetError>>>) -> Void) {
        getConfigurationGroup(matching: configuration.groupId, completionHandler: completionHandler)
    }

    // MARK: - ConfigurationGroup

    public func project(_ configurationGroup: ConfigurationGroup, completionHandler: @escaping (Outcome<Project, GetError>) -> Void) {
        getProject(configurationGroup.projectId, completionHandler: completionHandler)
    }

    // MARK: - Milestone

    public func parent(_ milestone: Milestone, completionHandler: @escaping (Outcome<Milestone?, GetError>) -> Void) {
        parent(milestone.parentId, completionHandler: completionHandler)
    }

    public func project(_ milestone: Milestone, completionHandler: @escaping (Outcome<Project, GetError>) -> Void) {
        getProject(milestone.projectId, completionHandler: completionHandler)
    }

    // MARK: - Plan

    public func assignedto(_ plan: Plan, completionHandler: @escaping (Outcome<User?, GetError>) -> Void) {
        assignedto(plan.assignedtoId, completionHandler: completionHandler)
    }

    public func createdBy(_ plan: Plan, completionHandler: @escaping (Outcome<User, GetError>) -> Void) {
        getUser(plan.createdBy, completionHandler: completionHandler)
    }

    public func milestone(_ plan: Plan, completionHandler: @escaping (Outcome<Milestone?, GetError>) -> Void) {
        milestone(plan.milestoneId, completionHandler: completionHandler)
    }

    public func project(_ plan: Plan, completionHandler: @escaping (Outcome<Project, GetError>) -> Void) {
        getProject(plan.projectId, completionHandler: completionHandler)
    }

    // MARK: - Plan.Entry

    public func suite(_ planEntry: Plan.Entry, completionHandler: @escaping (Outcome<Suite, GetError>) -> Void) {
        getSuite(planEntry.suiteId, completionHandler: completionHandler)
    }

    // MARK: - Result

    public func assignedto(_ result: Result, completionHandler: @escaping (Outcome<User?, GetError>) -> Void) {
        assignedto(result.assignedtoId, completionHandler: completionHandler)
    }

    public func createdBy(_ result: Result, completionHandler: @escaping (Outcome<User, GetError>) -> Void) {
        getUser(result.createdBy, completionHandler: completionHandler)
    }

    public func status(_ result: Result, completionHandler: @escaping (Outcome<Status?, MatchError<SingleMatchError<Result.Id>, GetError>>) -> Void) {
        status(matching: result.statusId, completionHandler: completionHandler)
    }

    public func test(_ result: Result, completionHandler: @escaping (Outcome<Test, GetError>) -> Void) {
        getTest(result.testId, completionHandler: completionHandler)
    }

    // MARK: - ResultField

    public func templates(_ resultField: ResultField, completionHandler: @escaping (Outcome<[Template], MatchError<MultipleMatchError<Template, Template.Id>, ErrorContainer<GetError>>>) -> Void) {
        getTemplates(matching: resultField.templateIds, completionHandler: completionHandler)
    }

    // MARK: - Run

    public func assignedto(_ run: Run, completionHandler: @escaping (Outcome<User?, GetError>) -> Void) {
        assignedto(run.assignedtoId, completionHandler: completionHandler)
    }

    public func configurations(_ run: Run, completionHandler: @escaping (Outcome<[Configuration]?, MatchError<MultipleMatchError<Configuration, Configuration.Id>, GetError>>) -> Void) {
        configurations(inProjectWithId: run.projectId, matching: run.configIds, completionHandler: completionHandler)
    }

    public func createdBy(_ run: Run, completionHandler: @escaping (Outcome<User, GetError>) -> Void) {
        getUser(run.createdBy, completionHandler: completionHandler)
    }

    public func milestone(_ run: Run, completionHandler: @escaping (Outcome<Milestone?, GetError>) -> Void) {
        milestone(run.milestoneId, completionHandler: completionHandler)
    }

    public func plan(_ run: Run, completionHandler: @escaping (Outcome<Plan?, GetError>) -> Void) {
        plan(run.planId, completionHandler: completionHandler)
    }

    public func project(_ run: Run, completionHandler: @escaping (Outcome<Project, GetError>) -> Void) {
        getProject(run.projectId, completionHandler: completionHandler)
    }

    public func suite(_ run: Run, completionHandler: @escaping (Outcome<Suite?, GetError>) -> Void) {
        suite(run.suiteId, completionHandler: completionHandler)
    }

    // MARK: - Section

    public func parent(_ section: Section, completionHandler: @escaping (Outcome<Section?, GetError>) -> Void) {
        parent(section.parentId, completionHandler: completionHandler)
    }

    public func suite(_ section: Section, completionHandler: @escaping (Outcome<Suite?, GetError>) -> Void) {
        suite(section.suiteId, completionHandler: completionHandler)
    }

    // MARK: - Suite

    public func project(_ suite: Suite, completionHandler: @escaping (Outcome<Project, GetError>) -> Void) {
        getProject(suite.projectId, completionHandler: completionHandler)
    }

    // MARK: - Test

    public func assignedto(_ test: Test, completionHandler: @escaping (Outcome<User?, GetError>) -> Void) {
        assignedto(test.assignedtoId, completionHandler: completionHandler)
    }

    public func `case`(_ test: Test, completionHandler: @escaping (Outcome<Case, GetError>) -> Void) {
        getCase(test.caseId, completionHandler: completionHandler)
    }

    public func milestone(_ test: Test, completionHandler: @escaping (Outcome<Milestone?, GetError>) -> Void) {
        milestone(test.milestoneId, completionHandler: completionHandler)
    }

    public func priority(_ test: Test, completionHandler: @escaping (Outcome<Priority, MatchError<SingleMatchError<Test.Id>, GetError>>) -> Void) {
        getPriority(matching: test.priorityId, completionHandler: completionHandler)
    }

    public func run(_ test: Test, completionHandler: @escaping (Outcome<Run, GetError>) -> Void) {
        getRun(test.runId, completionHandler: completionHandler)
    }

    public func status(_ test: Test, completionHandler: @escaping (Outcome<Status, MatchError<SingleMatchError<Test.Id>, GetError>>) -> Void) {
        getStatus(matching: test.statusId, completionHandler: completionHandler)
    }

    public func template(_ test: Test, completionHandler: @escaping (Outcome<Template, MatchError<SingleMatchError<Test.Id>, ErrorContainer<GetError>>>) -> Void) {
        getTemplate(matching: test.templateId, completionHandler: completionHandler)
    }

    public func type(_ test: Test, completionHandler: @escaping (Outcome<CaseType, MatchError<SingleMatchError<Test.Id>, GetError>>) -> Void) {
        getCaseType(matching: test.typeId, completionHandler: completionHandler)
    }

    // MARK: - Private Helpers

    // MARK: GET

    private func assignedto(_ userId: User.Id?, completionHandler: @escaping (Outcome<User?, GetError>) -> Void) {
        if let userId = userId {
            getUser(userId) { (outcome) in
                switch outcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(let user):
                    completionHandler(.success(user))
                }
            }
        } else {
            completionHandler(.success(nil))
        }
    }

    private func milestone(_ milestoneId: Milestone.Id?, completionHandler: @escaping (Outcome<Milestone?, GetError>) -> Void) {
        if let milestoneId = milestoneId {
            getMilestone(milestoneId) { (outcome) in
                switch outcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(let milestone):
                    completionHandler(.success(milestone))
                }
            }
        } else {
            completionHandler(.success(nil))
        }
    }

    private func milestone(_ milestoneId: Milestone.Id, completionHandler: @escaping (Outcome<Milestone, GetError>) -> Void) {
        getMilestone(milestoneId) { (outcome) in
            switch outcome {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let milestone):
                completionHandler(.success(milestone))
            }
        }
    }

    private func parent(_ milestoneId: Milestone.Id?, completionHandler: @escaping (Outcome<Milestone?, GetError>) -> Void) {
        milestone(milestoneId, completionHandler: completionHandler)
    }

    private func parent(_ milestoneId: Milestone.Id, completionHandler: @escaping (Outcome<Milestone, GetError>) -> Void) {
        milestone(milestoneId, completionHandler: completionHandler)
    }

    private func parent(_ sectionId: Section.Id?, completionHandler: @escaping (Outcome<Section?, GetError>) -> Void) {
        section(sectionId, completionHandler: completionHandler)
    }

    private func plan(_ planId: Plan.Id?, completionHandler: @escaping (Outcome<Plan?, GetError>) -> Void) {
        if let planId = planId {
            getPlan(planId) { (outcome) in
                switch outcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(let plan):
                    completionHandler(.success(plan))
                }
            }
        } else {
            completionHandler(.success(nil))
        }
    }

    private func section(_ sectionId: Section.Id?, completionHandler: @escaping (Outcome<Section?, GetError>) -> Void) {
        if let sectionId = sectionId {
            getSection(sectionId) { (outcome) in
                switch outcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(let section):
                    completionHandler(.success(section))
                }
            }
        } else {
            completionHandler(.success(nil))
        }
    }

    private func section(_ sectionId: Section.Id, completionHandler: @escaping (Outcome<Section, GetError>) -> Void) {
        getSection(sectionId) { (outcome) in
            switch outcome {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let section):
                completionHandler(.success(section))
            }
        }
    }

    private func suite(_ suiteId: Suite.Id?, completionHandler: @escaping (Outcome<Suite?, GetError>) -> Void) {
        if let suiteId = suiteId {
            getSuite(suiteId) { (outcome) in
                switch outcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(let suite):
                    completionHandler(.success(suite))
                }
            }
        } else {
            completionHandler(.success(nil))
        }
    }

    // MARK: Matching

    private func configurations(inProjectWithId projectId: Project.Id, matching configurationIds: [Configuration.Id]?, completionHandler: @escaping (Outcome<[Configuration]?, MatchError<MultipleMatchError<Configuration, Configuration.Id>, GetError>>) -> Void) {
        let uniqueConfigurationIds: Set<Configuration.Id>?
        if let configurationIds = configurationIds {
            uniqueConfigurationIds = Set(configurationIds)
        } else {
            uniqueConfigurationIds = nil
        }
        configurations(inProjectWithId: projectId, matching: uniqueConfigurationIds, completionHandler: completionHandler)
    }

    private func configurations(inProjectWithId projectId: Project.Id, matching configurationIds: [Configuration.Id], completionHandler: @escaping (Outcome<[Configuration], MatchError<MultipleMatchError<Configuration, Configuration.Id>, GetError>>) -> Void) {
        let uniqueIds = Set(configurationIds)
        configurations(inProjectWithId: projectId, matching: uniqueIds, completionHandler: completionHandler)
    }

    private func configurations(inProjectWithId projectId: Project.Id, matching configurationIds: Set<Configuration.Id>?, completionHandler: @escaping (Outcome<[Configuration]?, MatchError<MultipleMatchError<Configuration, Configuration.Id>, GetError>>) -> Void) {
        if let ids = configurationIds {
            getConfigurationGroups(inProjectWithId: projectId) { (outcome) in
                switch outcome {
                case .failure(let error):
                    completionHandler(.failure(.otherError(error)))
                case .success(let configurationGroups):
                    let configurations = configurationGroups.flatMap { $0.configs }
                    let matchesOutcome = ObjectAPI.matches(from: configurations, matchingIds: ids)
                    switch matchesOutcome {
                    case .failure(let error):
                        completionHandler(.failure(.matchError(error)))
                    case .success(let matches):
                        completionHandler(.success(matches))
                    }
                }
            }
        } else {
            completionHandler(.success(nil))
        }
    }

    private func configurations(inProjectWithId projectId: Project.Id, matching configurationIds: Set<Configuration.Id>, completionHandler: @escaping (Outcome<[Configuration], MatchError<MultipleMatchError<Configuration, Configuration.Id>, GetError>>) -> Void) {
        getConfigurationGroups(inProjectWithId: projectId) { (outcome) in
            switch outcome {
            case .failure(let error):
                completionHandler(.failure(.otherError(error)))
            case .success(let configurationGroups):
                let configurations = configurationGroups.flatMap { $0.configs }
                let matchesOutcome = ObjectAPI.matches(from: configurations, matchingIds: configurationIds)
                switch matchesOutcome {
                case .failure(let error):
                    completionHandler(.failure(.matchError(error)))
                case .success(let matches):
                    completionHandler(.success(matches))
                }
            }
        }
    }

    private func status(matching id: Status.Id?, completionHandler: @escaping (Outcome<Status?, MatchError<SingleMatchError<Status.Id>, GetError>>) -> Void) {
        if let id = id {
            getStatus(matching: id) { (outcome) in
                switch outcome {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(let status):
                    completionHandler(.success(status))
                }
            }
        } else {
            completionHandler(.success(nil))
        }
    }

    private func status(matching id: Status.Id, completionHandler: @escaping (Outcome<Status, MatchError<SingleMatchError<Status.Id>, GetError>>) -> Void) {
        getStatus(matching: id) { (outcome) in
            switch outcome {
            case .failure(let error):
                completionHandler(.failure(error))
            case .success(let status):
                completionHandler(.success(status))
            }
        }
    }

}
