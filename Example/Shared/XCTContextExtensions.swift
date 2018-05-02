import XCTest
import QuizTrain

extension XCTContext {

    @discardableResult public class func runActivity<Result>(named name: String? = nil, testing caseId: Case.Id, block: (XCTActivity) throws -> Result) rethrows -> Result {
        return try runActivity(named: name, testing: [caseId], block: block)
    }

    @discardableResult public class func runActivity<Result>(named name: String? = nil, testing caseIds: [Case.Id], block: (XCTActivity) throws -> Result) rethrows -> Result {

        let caseTitles = TestManager.sharedInstance.quizTrainManager.project.caseTitles(caseIds, withCaseId: true, withProjectName: false, withSuiteName: true, withSectionNames: true).joined(separator: " | ")

        let named: String
        if let name = name {
            named = name + ": " + caseTitles
        } else {
            named = caseTitles
        }

        startTesting(caseIds)
        let result = try XCTContext.runActivity(named: named, block: block)
        completeTesting(caseIds)

        return result
    }

}
