import QuizTrain
import XCTest

final class QuizTrainManager: NSObject {

    let objectAPI: ObjectAPI
    let project: QuizTrainProject

    var submitResults = true
    var closePlanAfterSubmittingResults = true
    var includeAllCasesInPlan = false

    init(objectAPI: ObjectAPI, project: QuizTrainProject) {
        self.objectAPI = objectAPI
        self.project = project
        super.init()
    }

    // MARK: - Outcome

    enum Outcome<Succeeded, Failed: Error> {
        case succeeded(Succeeded)
        case failed(Failed)
    }

    // MARK: - Testing

    enum Result: String {
        case passed
        case blocked
        case untested
        case retest
        case failed
    }

    private func status(_ result: Result) -> Status {
        return project.statuses.first(where: { $0.name == result.rawValue })!
    }

    private var assignedto: User {
        return project.users.first(where: { $0.email == objectAPI.api.username })! // All results are assigned to the API user account.
    }

    private func newResult(for caseId: Case.Id) -> NewCaseResults.Result {
        let untestedStatus = status(.untested)
        return NewCaseResults.Result(assignedtoId: assignedto.id, caseId: caseId, statusId: untestedStatus.id)
    }

    private var started = [NewCaseResults.Result]()
    private var completed = [NewCaseResults.Result]()

    /*
     Starts testing one or more caseIds. This adds a new NewCaseResults.Result
     to the |started| queue for each caseId with its result in an untested
     state. If any failures occur before a caseId is completed it will record
     those failures and be marked failed.

     For every caseId each startTesting call must be balanced with a
     completeTesting call. This can be done explicitly by you or implicitly by
     the XCTestObservation extension. See the extension for details.

     It is programmer error if you submit an identical caseId more than once to
     this queue.
     */
    func startTesting(_ caseIds: [Case.Id]) {
        for caseId in caseIds {
            guard started.filter({ $0.caseId == caseId }).count == 0 else {
                fatalError("You cannot start caseId \(caseId) because it has already been started.")
            }
            guard completed.filter({ $0.caseId == caseId }).count == 0 else {
                fatalError("You cannot start caseId \(caseId) because it has already been completed.")
            }
            started.append(newResult(for: caseId))
        }
    }

    func startTesting(_ caseIds: Case.Id...) {
        startTesting(caseIds)
    }

    fileprivate struct Failure {
        let test: XCTest
        let description: String
        let filePath: String?
        let lineNumber: Int
        var comment: String { return "Failure: \(test.name):\(filePath ?? ""):\(lineNumber): \(description)" }
    }

    /*
     Marks all results in the started queue as .failed and appends the failure
     comment to them.
     */
    fileprivate func recordFailure(_ failure: Failure) {
        let failedStatus = status(.failed)
        for i in started.indices {
            started[i].statusId = failedStatus.id
            if started[i].comment != nil {
                started[i].comment! += "\n\(failure.comment)"
            } else {
                started[i].comment = failure.comment
            }
        }
    }

    /*
     Completes testing |caseIds|. This:

     1. Removes them from the |started| queue.
     2. Changes their status to |result| if they are still .untested.
         - If they are not .untested their status is left unchanged.
     3. Appends the |comment|.
     4. Adds them to the |completed| queue.

     It is programmer error if you complete a caseId which is not currently
     started.
     */
    func completeTesting(_ caseIds: [Case.Id], withResultIfUntested result: Result = .passed, comment: String? = nil) {

        // Remove from started queue.
        var completed = [NewCaseResults.Result]()
        for caseId in caseIds {
            guard let complete = started.filter({ $0.caseId == caseId }).first,
                let index = started.firstIndex(of: complete) else {
                    fatalError("You cannot complete caseId \(caseId) because it has not been started.")
            }
            completed.append(complete)
            started.remove(at: index)
        }

        let status = self.status(result)
        let untestedStatus = self.status(.untested)

        for i in completed.indices {

            // Only set the status if untested.
            if completed[i].statusId == untestedStatus.id {
                completed[i].statusId = status.id
            }

            // Append comment.
            if let comment = comment {
                if completed[i].comment != nil {
                    completed[i].comment! += "\n\(comment)"
                } else {
                    completed[i].comment = comment
                }
            }
        }

        self.completed.append(contentsOf: completed)
    }

    func completeTesting(_ caseIds: Case.Id..., withResultIfUntested result: Result = .passed, comment: String? = nil) {
        completeTesting(caseIds, withResultIfUntested: result, comment: comment)
    }

    fileprivate func completeAllTests() {
        let casesIds = started.compactMap { $0.caseId }
        completeTesting(casesIds)
    }

}

// MARK: - TestRail

extension QuizTrainManager {

    // MARK: Results Parsing

    /*
     Returns a tuple splitting |results| into two arrays. Array 0 contains
     NewCaseResults.Result's whose caseIds appear in the project, and array 1
     contains those whose caseIds do not appear in the project.

     This is useful to identify results which were created with invalid/stale
     caseIds.
     */
    private func splitResults(_ results: [NewCaseResults.Result]) -> ([NewCaseResults.Result], [NewCaseResults.Result]) {

        var validResults = [NewCaseResults.Result]()
        var invalidResults = [NewCaseResults.Result]()

        for result in results {
            if project.cases.filter({ $0.id == result.caseId }).first != nil {
                validResults.append(result)
            } else {
                invalidResults.append(result)
            }
        }

        return (validResults, invalidResults)
    }

    // MARK: Submitting

    /*
     Creates a Plan with Entry's on TestRail, collects all |completed| results,
     filters out any caseIds which do not appear in QuizTrainProject and logs
     them, and submits the remaining valid results to the Plan.

     If |includingAllCases| is true then the created Plan will include all
     cases in the project. Otherwise it will only include those which are
     completed.

     If |closePlan| is true the plan will be closed after it's submitted. You
     cannot unclose a closed plan.

     This method blocks while asynchronous requests to TestRail are occurring.
     */
    fileprivate func submitResultsToTestRail(includingAllCases: Bool = false, closingPlanAfterSubmittingResults closePlan: Bool = true) {

        // Filter valid/invalid results.
        let (validResults, invalidResults) = splitResults(completed)
        if invalidResults.isEmpty == false {
            print("--------------------------------------")
            print("WARNING: The following results are for invalid caseIds and will not be submitted to TestRail.")
            for result in invalidResults {
                let status: Status? = project[result.statusId!]
                print("\(result.caseId): \(status?.name ?? "") - \(result.comment ?? "")")
            }
            print("--------------------------------------")
        }
        let validCaseIds = validResults.map { $0.caseId }

        // Get Case's for all valid results.
        var cases = [Case]()
        for caseId in validCaseIds {
            guard let `case`: Case = project[caseId] else {
                fatalError("There is no Case for caseId \(caseId) in project: \(project)")
            }
            guard cases.contains(where: { $0.id == caseId }) == false else {
                continue // skip duplicates
            }
            cases.append(`case`)
        }

        // Create NewPlan.Entry's for every included Suite.
        var newPlanEntries = [NewPlan.Entry]()
        if includingAllCases {
            for suite in project.suites {
                newPlanEntries.append(NewPlan.Entry(includeAll: true, suiteId: suite.id))
            }
        } else {

            // Only include suite's for tested cases.
            var suites = [Suite]()
            for `case` in cases {
                guard let suiteId = `case`.suiteId else {
                    fatalError("Case does not have a suiteId: \(`case`)")
                }
                guard let suite: Suite = project[suiteId] else {
                    fatalError("There is no Suite for suiteId \(suiteId) in project: \(project)")
                }
                guard suites.contains(suite) == false else {
                    continue
                }
                suites.append(suite)
            }

            // For each suite only include the cases tested in that suite.
            for suite in suites {
                let casesInSuite = cases.filter { $0.suiteId == suite.id }
                let caseIdsInSuite = casesInSuite.map { $0.id }
                let newPlanEntry = NewPlan.Entry(assignedtoId: assignedto.id, caseIds: caseIdsInSuite, includeAll: false, suiteId: suite.id)
                newPlanEntries.append(newPlanEntry)
            }
        }

        let group = DispatchGroup()

        // Create a Plan.
        print("Plan creation started.")
        guard !validResults.isEmpty else {
            print("Plan creation skipped. There are no results to submit.")
            return
        }
        let newPlan = NewPlan(description: "Created with QuizTrain - https://github.com/venmo/QuizTrain", entries: newPlanEntries, name: "QuizTrain Test Results")
        var plan: Plan!
        group.enter()
        objectAPI.addPlan(newPlan, to: project.project) { (outcome) in
            switch outcome {
            case .failed(let error):
                print("Plan creation failed: \(error.debugDescription)")
                return
            case .succeeded(let aPlan):
                plan = aPlan
            }
            group.leave()
        }
        group.wait()
        print("Plan creation completed. \(plan.url)")

        guard let planEntries = plan.entries, planEntries.count > 0 else {
            print("Aborting: There are no entries in the plan: \(String(describing: plan))")
            return
        }

        // Submit results.
        print("Submitting \(validResults.count) test results started.")
        var errors = [ObjectAPI.AddError]()
        var results = [QuizTrain.Result]()
        for planEntry in planEntries {
            for run in planEntry.runs {

                // Include results in this Run.
                let casesInRun = cases.filter { $0.suiteId == run.suiteId } // We detect the run a case belongs in using the suiteId.
                let caseIdsInRun = casesInRun.map { $0.id }
                var resultsForRun = [NewCaseResults.Result]()
                for caseId in caseIdsInRun {
                    guard let result = validResults.filter({ $0.caseId == caseId }).first else {
                        continue
                    }
                    resultsForRun.append(result)
                }

                guard resultsForRun.isEmpty == false else {
                    continue // TestRail will return an error if you submit zero results for a run.
                }

                let newCaseResults = NewCaseResults(results: resultsForRun)

                group.enter()
                objectAPI.addResultsForCases(newCaseResults, to: run) { (outcome) in
                    switch outcome {
                    case .failed(let error):
                        errors.append(error)
                    case .succeeded(let someResults):
                        results.append(contentsOf: someResults)
                    }
                    group.leave()
                }
            }
        }
        group.wait()

        guard errors.count == 0 else {
            print("Submitting test results failed with \(errors.count) error(s):")
            for error in errors {
                print(error.debugDescription)
            }
            return
        }

        print("Submitting \(results.count) test results completed.")

        if closePlan {
            print("Closing plan started.")
            group.enter()
            objectAPI.closePlan(plan) { (outcome) in
                switch outcome {
                case .failed(let error):
                    print("Closing plan failed: \(error)")
                case .succeeded(_):
                    break
                }
                group.leave()
            }
            group.wait()
            print("Closing plan completed.")
        }
    }

}

// MARK: - XCTestObservation

extension QuizTrainManager: XCTestObservation {

    public func testBundleWillStart(_ testBundle: Bundle) {
        completeAllTests()
    }

    public func testSuiteWillStart(_ testSuite: XCTestSuite) {
        completeAllTests()
    }

    public func testCaseWillStart(_ testCase: XCTestCase) {
        completeAllTests()
    }

    public func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        recordFailure(Failure(test: testCase, description: description, filePath: filePath, lineNumber: lineNumber))
    }

    public func testCaseDidFinish(_ testCase: XCTestCase) {
        completeAllTests()
    }

    public func testSuite(_ testSuite: XCTestSuite, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: Int) {
        recordFailure(Failure(test: testSuite, description: description, filePath: filePath, lineNumber: lineNumber))
    }

    public func testSuiteDidFinish(_ testSuite: XCTestSuite) {
        completeAllTests()
    }
    public func testBundleDidFinish(_ testBundle: Bundle) {
        completeAllTests()

        print("\n========== QuizTrainManager ==========\n")
        if submitResults {
            submitResultsToTestRail(includingAllCases: includeAllCasesInPlan, closingPlanAfterSubmittingResults: closePlanAfterSubmittingResults) // blocking
        } else {
            print("Submitting results is disabled.")
        }
        print("\n======================================\n")
    }

}
