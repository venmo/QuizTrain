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
        #error("Update these ObjectAPI arguments below for your TestRail instance. Then comment out this macro.")
        let objectAPI = QuizTrain.ObjectAPI(username: "YOUR@TESTRAIL.EMAIL", secret: "YOUR_TESTRAIL_PASSWORD_OR_API_KEY", hostname: "YOURINSTANCE.testrail.net", port: 443, scheme: "https")
        var quizTrainManager: QuizTrainManager!
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global().async {
            #error("Replace the projectId below with one from your TestRail instance. Then comment out this macro.")
            QuizTrainProject.populatedProject(forProjectId: 99999, objectAPI: objectAPI) { (outcome) in
                switch outcome {
                case .failure(let error):
                    print("QuizTrainManager setup failed: \(error)")
                    fatalError(error.localizedDescription)
                case .success(let project):
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
