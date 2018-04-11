import Foundation
import QuizTrain
import XCTest

/*
 Principal Class for test targets owned by their Bundle. This should be accessed
 using its singleton property: TestManager.sharedInstance

 Performs logic required before any tests run and after all tests complete.
 */
final class TestManager: NSObject {

    let quizTrainManager: QuizTrainManager

    override init() {

        print("\n========== TestManager ==========\n")
        defer { print("\n====================================\n") }

        print("QuizTrainManager setup started.")
        let objectAPI = QuizTrain.ObjectAPI(username: "YOUR@TESTRAIL.EMAIL", secret: "YOUR_TESTRAIL_PASSWORD_OR_API_KEY", hostname: "YOURINSTANCE.testrail.net", port: 443, scheme: "https") // TODO: Update these arguments for your TestRail instance.
        var quizTrainManager: QuizTrainManager!
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            QuizTrainProject.populatedProject(forProjectId: 99999, objectAPI: objectAPI) { (outcome) in // TODO: Replace the projectId with one from your TestRail instance.
                switch outcome {
                case .failed(let error):
                    print("QuizTrainManager setup failed: \(error)")
                    fatalError(error.localizedDescription)
                case .succeeded(let project):
                    quizTrainManager = QuizTrainManager(objectAPI: objectAPI, project: project)
                }
                group.leave()
            }
        }
        group.wait()
        self.quizTrainManager = quizTrainManager
        XCTestObservationCenter.shared.addTestObserver(self.quizTrainManager)
        print("QuizTrainManager setup completed.")

        super.init()

        TestManager._sharedInstance = self
    }

    deinit {
        XCTestObservationCenter.shared.removeTestObserver(self.quizTrainManager)
    }

    // MARK: - Singleton

    private static var _sharedInstance: TestManager!

    static var sharedInstance: TestManager {
        return _sharedInstance
    }

}

// MARK: - Global

func logTest(_ caseIds: [Case.Id], withCaseId: Bool = true, withProjectName: Bool = false, withSuiteName: Bool = true, withSectionNames: Bool = true) {
    let caseTitles = TestManager.sharedInstance.quizTrainManager.project.caseTitles(caseIds, withCaseId: withCaseId, withProjectName: withProjectName, withSuiteName: withSuiteName, withSectionNames: withSectionNames)
    for caseTitle in caseTitles {
        print(caseTitle)
    }
}

func logTest(_ caseIds: Case.Id..., withCaseId: Bool = true, withProjectName: Bool = false, withSuiteName: Bool = true, withSectionNames: Bool = true) {
    logTest(caseIds, withCaseId: withCaseId, withProjectName: withProjectName, withSuiteName: withSuiteName, withSectionNames: withSectionNames)
}

func logAndStartTesting(_ caseIds: [Case.Id]) {
    logTest(caseIds)
    startTesting(caseIds)
}

func logAndStartTesting(_ caseIds: Case.Id...) {
    logTest(caseIds)
    startTesting(caseIds)
}

func startTesting(_ caseIds: [Case.Id]) {
    TestManager.sharedInstance.quizTrainManager.startTesting(caseIds)
}

func startTesting(_ caseIds: Case.Id...) {
    TestManager.sharedInstance.quizTrainManager.startTesting(caseIds)
}

func completeTesting(_ caseIds: [Case.Id], withResultIfUntested result: QuizTrainManager.Result = .passed, comment: String? = nil) {
    TestManager.sharedInstance.quizTrainManager.completeTesting(caseIds, withResultIfUntested: result, comment: comment)
}

func completeTesting(_ caseIds: Case.Id..., withResultIfUntested result: QuizTrainManager.Result = .passed, comment: String? = nil) {
    TestManager.sharedInstance.quizTrainManager.completeTesting(caseIds, withResultIfUntested: result, comment: comment)
}
