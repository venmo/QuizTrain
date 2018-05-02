import QuizTrain

struct QuizTrainProject {

    // MARK: - Properties

    let project: QuizTrain.Project
    let suites: [QuizTrain.Suite]
    let sections: [QuizTrain.Section]
    let cases: [QuizTrain.Case]
    let statuses: [QuizTrain.Status]
    let users: [QuizTrain.User]

    // MARK: - Relationships

    func suite(_ section: QuizTrain.Section) -> QuizTrain.Suite {
        return suites.first(where: { $0.id == section.suiteId })! // Sections should always have a Suite
    }

    func suite(_ `case`: QuizTrain.Case) -> QuizTrain.Suite {
        return suites.first(where: { $0.id == `case`.suiteId })! // Cases should always have a Suite
    }

    func sections(_ suite: QuizTrain.Suite) -> [QuizTrain.Section] {
        return sections.filter { $0.suiteId == suite.id }
    }

    func parentSection(_ section: QuizTrain.Section) -> QuizTrain.Section? {
        return sections.first(where: { $0.id == section.parentId })
    }

    func childSections(_ section: QuizTrain.Section) -> [QuizTrain.Section]? {
        return sections.filter { $0.parentId == section.id }
    }

    func section(_ `case`: QuizTrain.Case) -> QuizTrain.Section {
        return sections.first(where: { $0.id == `case`.sectionId })! // Cases should always have a Section
    }

    func cases(_ suite: QuizTrain.Suite) -> [QuizTrain.Case] {
        return cases.filter { $0.suiteId == suite.id }
    }

    func cases(_ section: QuizTrain.Section) -> [QuizTrain.Case] {
        return cases.filter { $0.sectionId == section.id }
    }

    // MARK: - Subscripting

    subscript(suiteId: QuizTrain.Suite.Id) -> QuizTrain.Suite? {
        return suites.first(where: { $0.id == suiteId })
    }

    subscript(sectionId: QuizTrain.Section.Id) -> QuizTrain.Section? {
        return sections.first(where: { $0.id == sectionId })
    }

    subscript(caseId: QuizTrain.Case.Id) -> QuizTrain.Case? {
        return cases.first(where: { $0.id == caseId })
    }

    subscript(statusId: QuizTrain.Status.Id) -> QuizTrain.Status? {
        return statuses.first(where: { $0.id == statusId })
    }

    subscript(userId: QuizTrain.User.Id) -> QuizTrain.User? {
        return users.first(where: { $0.id == userId })
    }

    // MARK: - Strings

    /*
     Generates strings for a caseId like so:

     "C[CASEID]: /PROJECT.NAME/SUITE.NAME/SECTION1.NAME/SECTION2.NAME/ - CASE.TITLE

     If no caseID match is found returns: "INVALID_CASEID_12345"
     */
    func caseTitle(_ caseId: QuizTrain.Case.Id, withCaseId: Bool = true, withProjectName: Bool = false, withSuiteName: Bool = true, withSectionNames: Bool = true) -> String {

        guard let `case`: QuizTrain.Case = self[caseId] else {
            return "INVALID_CASEID_\(caseId)"
        }

        var string = ""

        if withCaseId {
            string.append("C\(caseId): ")
        }

        if withProjectName {
            string.append("/\(project.name)")
        }

        if withSuiteName {
            string.append("/\(suite(`case`).name)")
        }

        if withSectionNames {

            var childSection = section(`case`)
            var sectionNames = [childSection.name]

            while let parentSection = self.parentSection(childSection) {
                sectionNames.append(parentSection.name)
                childSection = parentSection
            }

            sectionNames = sectionNames.reversed()

            for index in 0..<sectionNames.count {
                string.append("/\(sectionNames[index])")
            }
        }

        if withProjectName || withSuiteName || withSectionNames {
            string.append("/ - ")
        }

        string.append("\(`case`.title)")

        return string
    }

    func caseTitles(_ caseIdVarArgs: QuizTrain.Case.Id..., withCaseId: Bool = true, withProjectName: Bool = false, withSuiteName: Bool = true, withSectionNames: Bool = true) -> [String] {
        return caseTitles(caseIdVarArgs, withCaseId: withCaseId, withProjectName: withProjectName, withSuiteName: withSuiteName, withSectionNames: withSectionNames)
    }

    func caseTitles(_ caseIds: [QuizTrain.Case.Id], withCaseId: Bool = true, withProjectName: Bool = false, withSuiteName: Bool = true, withSectionNames: Bool = true) -> [String] {
        var caseTitles = [String]()
        for caseId in caseIds {
            caseTitles.append(caseTitle(caseId, withCaseId: withCaseId, withProjectName: withProjectName, withSuiteName: withSuiteName, withSectionNames: withSectionNames))
        }
        return caseTitles
    }

    // MARK: - Creation

    enum Outcome<Succeeded, Failed: Error> {
        case succeeded(Succeeded)
        case failed(Failed)
    }

    /*
     Asynchronously calls the ObjectAPI and populates a QuizTrainProject.
     */
    static func populatedProject(forProjectId projectId: QuizTrain.Project.Id, objectAPI: QuizTrain.ObjectAPI, completionHandler: @escaping (Outcome<QuizTrainProject, QuizTrain.ObjectAPI.GetError>) -> Void) {
        DispatchQueue.global().async {

            let group = DispatchGroup()

            // Get Project, Suites, Statuses, and Users concurrently.

            group.enter()
            var projectOutcome: QuizTrain.Outcome<QuizTrain.Project, QuizTrain.ObjectAPI.GetError>!
            objectAPI.getProject(projectId) { (outcome) in
                projectOutcome = outcome
                group.leave()
            }

            group.enter()
            var suitesOutcome: QuizTrain.Outcome<[QuizTrain.Suite], QuizTrain.ObjectAPI.GetError>!
            objectAPI.getSuites(inProjectWithId: projectId) { (outcome) in
                suitesOutcome = outcome
                group.leave()
            }

            group.enter()
            var statusesOutcome: QuizTrain.Outcome<[QuizTrain.Status], QuizTrain.ObjectAPI.GetError>!
            objectAPI.getStatuses { (outcome) in
                statusesOutcome = outcome
                group.leave()
            }

            group.enter()
            var usersOutcome: QuizTrain.Outcome<[QuizTrain.User], QuizTrain.ObjectAPI.GetError>!
            objectAPI.getUsers { (outcome) in
                usersOutcome = outcome
                group.leave()
            }

            group.wait()

            let project: QuizTrain.Project
            switch projectOutcome! {
            case .failed(let error):
                completionHandler(.failed(error))
                return
            case .succeeded(let aProject):
                project = aProject
            }

            let suites: [QuizTrain.Suite]
            switch suitesOutcome! {
            case .failed(let error):
                completionHandler(.failed(error))
                return
            case .succeeded(let someSuites):
                suites = someSuites
            }

            let statuses: [QuizTrain.Status]
            switch statusesOutcome! {
            case .failed(let error):
                completionHandler(.failed(error))
                return
            case .succeeded(let someStatuses):
                statuses = someStatuses
            }

            let users: [QuizTrain.User]
            switch usersOutcome! {
            case .failed(let error):
                completionHandler(.failed(error))
                return
            case .succeeded(let someUsers):
                users = someUsers
            }

            // Get Cases and Sections concurrently.

            var casesOutcomes = [QuizTrain.Outcome<[QuizTrain.Case], QuizTrain.ObjectAPI.GetError>]()
            var sectionsOutcomes = [QuizTrain.Outcome<[QuizTrain.Section], QuizTrain.ObjectAPI.GetError>]()

            for suite in suites {

                group.enter()
                objectAPI.getCases(in: project, in: suite) { (outcome) in
                    casesOutcomes.append(outcome)
                    group.leave()
                }

                group.enter()
                objectAPI.getSections(in: project, in: suite) { (outcome) in
                    sectionsOutcomes.append(outcome)
                    group.leave()
                }
            }

            group.wait()

            var cases = [QuizTrain.Case]()
            for casesOutcome in casesOutcomes {
                switch casesOutcome {
                case .failed(let error):
                    completionHandler(.failed(error))
                    return
                case .succeeded(let someCases):
                    cases.append(contentsOf: someCases)
                }
            }

            var sections = [QuizTrain.Section]()
            for sectionsOutcome in sectionsOutcomes {
                switch sectionsOutcome {
                case .failed(let error):
                    completionHandler(.failed(error))
                    return
                case .succeeded(let someSections):
                    sections.append(contentsOf: someSections)
                }
            }

            // Assemble the QuizTrainProject with all data.

            let quizTrainProject = QuizTrainProject(project: project, suites: suites, sections: sections, cases: cases, statuses: statuses, users: users)
            completionHandler(.succeeded(quizTrainProject))
        }
    }

}
