import XCTest
@testable import QuizTrain

/**
 ObjectAPI end-to-end tests. These tests run against a real-world TestRail
 instance. Sections:

 - Initialization, deinit, stored properties.
 - Shared Setup/Teardown logic. This created/destroys a TestProject to be used
   during testing.
 - Data Provider logic. This provides data for objects used during tests.
 - Tests separated into related sections (Arrange).
 - Assertions separated into related sections used by tests. These perform API
   requests and assert their results (Act, Assert). In some cases tests may
   perform extra assertions based on the context of a specific test.

 Tests will create and delete several projects and their contents during
 testing. They will not delete anything else unless you or someone modifies them
 to do so. Generally it is safe to run tests against production so long as you
 are OK with rate limits potentially being triggered while tests run and with
 tests reading some production data in your instance. Even so it is advised that
 you backup your production instance fully before running tests and verify that
 the backup is valid.

 If tests crash rouge test projects may be abandoned in your instance. Their
 names will be prefixed with "QuizTrainTests". It is safe to delete them so long
 as you have no production projects starting with the same name.

 If any testAdd*CaseField() tests are run then you will have to manually remove
 any CaseField's created by tests using your TestRail administration portal.
 Tests are unable to remove these automatically because there is no public API
 endpoint to do so. Because of this these tests are disabled by default in all
 testing schemes. See the QuizTrainTests README.md for more details.

 For tests to run you must populate TestCredentials.json with all properties
 required by TestCredentials.swift.

 The user must have permissions to create/read/update/delete projects and all
 objects inside of them. Furthermore any required custom fields you have created
 must either have default values set, or be temporarily unmarked as required,
 for tests to run. Alternatively you can add your required custom field data to
 appropriate objects in the "Data Provider" section.
 */
class ObjectAPITests: XCTestCase {

    let timeout = 60.0
    let objectCount = 2                                                         // Quantity of each object in TestProject to create. This should be 2 or higher for tests to work well. Values higher than 3 might slow down setUp and tests considerably due to rate limiting.

    static var testCredentials: TestCredentials!
    var testCredentials: TestCredentials! { get { return ObjectAPITests.testCredentials } set { ObjectAPITests.testCredentials = newValue } }

    static var objectAPI: ObjectAPI!
    var objectAPI: ObjectAPI! { get { return ObjectAPITests.objectAPI } set { ObjectAPITests.objectAPI = newValue } }

    static var testProject: TestProject!
    var testProject: TestProject! { get { return ObjectAPITests.testProject } set { ObjectAPITests.testProject = newValue } }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        setUpTestCredentials()
        setUpObjectAPI()
        setUpTestProject()
        continueAfterFailure = true
    }

    override static func tearDown() {
        super.tearDown()
        tearDownTestProject()
    }

}

// MARK: - TestProject

extension ObjectAPITests {

    struct TestProject {
        var cases: [Case]
        var caseFields: [CaseField]
        var configurationGroups: [ConfigurationGroup]
        var configurations: [Configuration]
        var milestones: [Milestone]
        var plans: [Plan]
        var project: Project
        var resultFields: [ResultField]
        var runs: [Run]
        var sections: [Section]
        var suites: [Suite]
        var templates: [Template]
        var tests: [Test]
        var user: User
    }

}

// MARK: - Setup/Teardown

extension ObjectAPITests {

    func setUpTestCredentials() {

        guard testCredentials == nil else {
            return
        }

        do {
            let bundle = Bundle(for: type(of: self))
            testCredentials = try TestCredentials.load(from: bundle)
        } catch {
            XCTFail("FAILED: \(#file):\(#line):\(#function): \(error)")
        }
    }

    func setUpObjectAPI() {

        guard objectAPI == nil else {
            return
        }

        guard testCredentials != nil else {
            XCTFail("FAILED: \(#file):\(#line):\(#function)")
            return
        }

        objectAPI = ObjectAPI(username: testCredentials.username, secret: testCredentials.secret, hostname: testCredentials.hostname, port: testCredentials.port, scheme: testCredentials.scheme)
    }

    // swiftlint:disable:next cyclomatic_complexity
    func setUpTestProject() {

        guard testProject == nil else {
            return
        }

        continueAfterFailure = false

        // Project

        let newProject = NewProject(announcement: "Project Announcement", name: "QuizTrainTests - Test Project", showAnnouncement: true, suiteMode: .multipleSuites)
        guard let project = assertAddProject(newProject) else {
            XCTFail("FAILED: \(#file):\(#line):\(#function)")
            return
        }

        defer {
            // If setup fails delete the test project from TestRail. This will
            // also delete any other objects created below in the project.
            if testProject == nil {
                continueAfterFailure = true
                assertDeleteProject(project)
                XCTFail("FAILED: \(#file):\(#line):\(#function)")
            }
        }

        // Suites

        var suites = [Suite]()

        for i in 0..<objectCount {
            let newSuite = NewSuite(description: "Suite Description \(i + 1)", name: "TP: Suite Name \(i + 1)")
            guard let suite = assertAddSuite(newSuite, to: project) else {
                return
            }
            suites.append(suite)
        }

        // Sections

        var sections = [Section]()

        for suite in suites {
            for i in 0..<objectCount {
                let newSection = NewSection(description: "Section Description \(i + 1)", name: "TP: Section Name \(i + 1)", parentId: nil, suiteId: suite.id)
                guard let section = assertAddSection(newSection, to: project) else {
                    return
                }
                sections.append(section)
            }
        }

        // Milestones

        var milestones = [Milestone]()

        for i in 0..<objectCount {
            let newMilestone = NewMilestone(description: "Milestone Description \(i + 1)", dueOn: nil, name: "TP: Milestone Name \(i + 1)", parentId: nil, startOn: nil)
            guard let milestone = assertAddMilestone(newMilestone, to: project) else {
                return
            }
            milestones.append(milestone)
        }

        // Templates

        guard let templates = assertGetTemplates(in: project) else {
            return
        }

        // Plans w/Plan.Entry's

        var plans = [Plan]()

        for milestone in milestones {
            for i in 0..<objectCount {
                var newPlanEntries = [NewPlan.Entry]()
                for i in 0..<objectCount {
                    let newPlanEntry = NewPlan.Entry(assignedtoId: nil, caseIds: nil, description: "Plan.Entry Description \(i)", includeAll: true, name: "TP: Plan.Entry Name \(i + 1)", runs: nil, suiteId: suites.randomElement!.id)
                    newPlanEntries.append(newPlanEntry)
                }
                let newPlan = NewPlan(description: "Plan Description \(i + 1)", entries: newPlanEntries, milestoneId: milestone.id, name: "TP: Plan Name \(i + 1)")
                guard let plan = assertAddPlan(newPlan, to: project) else {
                    return
                }
                plans.append(plan)
            }
        }

        // Cases

        var cases = [Case]()

        for section in sections {
            for i in 0..<objectCount {
                let newCase = NewCase(estimate: nil, milestoneId: nil, priorityId: nil, refs: nil, templateId: nil, title: "TP: Case Title \(i + 1)", typeId: nil, customFields: nil)
                guard let `case` = assertAddCase(newCase, to: section) else {
                    return
                }
                cases.append(`case`)
            }
        }

        // ConfigurationGroups

        var configurationGroups = [ConfigurationGroup]()

        for i in 0..<objectCount {
            let newConfigurationGroup = NewConfigurationGroup(name: "TP: ConfigurationGroup Name \(i + 1)")
            guard let configurationGroup = assertAddConfigurationGroup(newConfigurationGroup, to: project) else {
                return
            }
            configurationGroups.append(configurationGroup)
        }

        // Configurations

        var configurations = [Configuration]()

        for configurationGroup in configurationGroups {
            for i in 0..<objectCount {
                let newConfiguration = NewConfiguration(name: "TP: Configuration Name \(i + 1)")
                guard let configuration = assertAddConfiguration(newConfiguration, to: configurationGroup) else {
                    return
                }
                configurations.append(configuration)
            }
        }

        // Runs

        var runs = [Run]()

        for suite in suites {
            for i in 0..<objectCount {
                let newRun = NewRun(assignedtoId: nil, caseIds: nil, description: nil, includeAll: true, milestoneId: nil, name: "TP: Run Name \(i + 1)", suiteId: suite.id)
                guard let run = assertAddRun(newRun, to: project) else {
                    return
                }
                runs.append(run)
            }
        }

        // Tests

        var tests = [Test]()

        for run in runs {
            guard let runTests = assertGetTests(in: run) else {
                return
            }
            tests.append(contentsOf: runTests)
        }

        // User

        guard let user = assertGetUserByEmail(objectAPI.api.username) else {
            return
        }

        // CaseFields

        guard let caseFields = assertGetCaseFields() else {
            return
        }

        // ResultFields

        guard let resultFields = assertGetResultFields() else {
            return
        }

        testProject = TestProject(cases: cases, caseFields: caseFields, configurationGroups: configurationGroups, configurations: configurations, milestones: milestones, plans: plans, project: project, resultFields: resultFields, runs: runs, sections: sections, suites: suites, templates: templates, tests: tests, user: user)
    }

    static func tearDownTestProject() {

        guard testProject != nil else {
            return
        }

        objectAPI.deleteProject(testProject.project) { (_) in return }
        sleep(5) // Wait for the async API call to kickoff; we can't use expectations in static methods.
        testProject = nil
    }

}

// MARK: - Data Provider

extension ObjectAPITests {

    enum Properties {
        case requiredProperties
        case requiredAndOptionalProperties
    }

    func newCase(with properties: Properties) -> NewCase {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCase = NewCase(estimate: nil,
                              milestoneId: nil,
                              priorityId: nil,
                              refs: nil,
                              templateId: nil,
                              title: "Test Add: Case Title",
                              typeId: nil,
                              customFields: nil)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCase.estimate = "3m"
            newCase.milestoneId = nil // Setting the milestoneId does not appear to work.
            newCase.priorityId = 3
            newCase.refs = "RF-1, RF-2"
            newCase.templateId = testProject.templates[0].id
            newCase.typeId = 1
            // data.customFields can be set by caller if necessary.
        }

        return newCase
    }

    func newCaseFieldString(with properties: Properties) -> NewCaseField<NewCaseFieldStringData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseField = NewCaseField<NewCaseFieldStringData>(description: nil,
                                                                label: "Test Add: String",
                                                                name: "quiztraintests_\(randomString())",
                                                                includeAll: true,
                                                                templateIds: [],
                                                                isGlobal: true,
                                                                projectIds: [],
                                                                isRequired: false,
                                                                defaultValue: nil)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
            newCaseField.data.configs[0].options.defaultValue = "Hello QuizTrain"
        }

        return newCaseField
    }

    func newCaseFieldInteger(with properties: Properties) -> NewCaseField<NewCaseFieldIntegerData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseField = NewCaseField<NewCaseFieldIntegerData>(description: nil,
                                                                 label: "Test Add: Integer",
                                                                 name: "quiztraintests_\(randomString())",
                                                                 includeAll: true,
                                                                 templateIds: [],
                                                                 isGlobal: true,
                                                                 projectIds: [],
                                                                 isRequired: false,
                                                                 defaultValue: nil)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
            newCaseField.data.configs[0].options.defaultValue = 999
        }

        return newCaseField
    }

    func newCaseFieldText(with properties: Properties) -> NewCaseField<NewCaseFieldTextData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseField = NewCaseField<NewCaseFieldTextData>(description: nil,
                                                              label: "Test Add: Text",
                                                              name: "quiztraintests_\(randomString())",
                                                              includeAll: true,
                                                              templateIds: [],
                                                              isGlobal: true,
                                                              projectIds: [],
                                                              isRequired: false,
                                                              defaultValue: nil,
                                                              format: .markdown,
                                                              rows: .unspecified)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
            newCaseField.data.configs[0].options.defaultValue = "Hello QuizTrain"
            newCaseField.data.configs[0].options.rows = .three
        }

        return newCaseField
    }

    func newCaseFieldURL(with properties: Properties) -> NewCaseField<NewCaseFieldURLData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseField = NewCaseField<NewCaseFieldURLData>(description: nil,
                                                             label: "Test Add: URL",
                                                             name: "quiztraintests_\(randomString())",
                                                             includeAll: true,
                                                             templateIds: [],
                                                             isGlobal: true,
                                                             projectIds: [],
                                                             isRequired: false,
                                                             defaultValue: nil)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
            newCaseField.data.configs[0].options.defaultValue = URL(string: "https://github.com/venmo/QuizTrain/")
        }

        return newCaseField
    }

    func newCaseFieldCheckbox(with properties: Properties) -> NewCaseField<NewCaseFieldCheckboxData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseField = NewCaseField<NewCaseFieldCheckboxData>(description: nil,
                                                                  label: "Test Add: Checkbox",
                                                                  name: "quiztraintests_\(randomString())",
                                                                  includeAll: true,
                                                                  templateIds: [],
                                                                  isGlobal: true,
                                                                  projectIds: [],
                                                                  isRequired: false,
                                                                  defaultValue: false)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
        }

        return newCaseField
    }

    func newCaseFieldDropdown(with properties: Properties) -> NewCaseField<NewCaseFieldDropdownData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        // Dropdown will throw if `defaultValue` is of out of bounds of `items` or if `items` is empty.
        var newCaseField: NewCaseField<NewCaseFieldDropdownData>
        do {
            let items = ["One", "Two", "Three"]
            newCaseField = try NewCaseField<NewCaseFieldDropdownData>(description: nil,
                                                                      label: "Test Add: Dropdown",
                                                                      name: "quiztraintests_\(randomString())",
                                                                      includeAll: true,
                                                                      templateIds: [],
                                                                      isGlobal: true,
                                                                      projectIds: [],
                                                                      isRequired: false,
                                                                      items: items,
                                                                      defaultValue: (items.count - 1))
        } catch {
            fatalError(error.localizedDescription)
        }

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
        }

        return newCaseField
    }

    func newCaseFieldUser(with properties: Properties) -> NewCaseField<NewCaseFieldUserData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseField = NewCaseField<NewCaseFieldUserData>(description: nil,
                                                              label: "Test Add: User",
                                                              name: "quiztraintests_\(randomString())",
                                                              includeAll: true,
                                                              templateIds: [],
                                                              isGlobal: true,
                                                              projectIds: [],
                                                              isRequired: false,
                                                              defaultValue: nil)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
            newCaseField.data.configs[0].options.defaultValue = testProject.user.id
        }

        return newCaseField
    }

    func newCaseFieldDate(with properties: Properties) -> NewCaseField<NewCaseFieldDateData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseField = NewCaseField<NewCaseFieldDateData>(description: nil,
                                                              label: "Test Add: Date",
                                                              name: "quiztraintests_\(randomString())",
                                                              includeAll: true,
                                                              templateIds: [],
                                                              isGlobal: true,
                                                              projectIds: [],
                                                              isRequired: false)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
        }

        return newCaseField
    }

    func newCaseFieldMilestone(with properties: Properties) -> NewCaseField<NewCaseFieldMilestoneData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseField = NewCaseField<NewCaseFieldMilestoneData>(description: nil,
                                                                   label: "Test Add: Milestone",
                                                                   name: "quiztraintests_\(randomString())",
                                                                   includeAll: true,
                                                                   templateIds: [],
                                                                   isGlobal: true,
                                                                   projectIds: [],
                                                                   isRequired: false)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
        }

        return newCaseField
    }

    func newCaseFieldSteps(with properties: Properties) -> NewCaseField<NewCaseFieldStepsData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseField = NewCaseField<NewCaseFieldStepsData>(description: nil,
                                                               label: "Test Add: Steps",
                                                               name: "quiztraintests_\(randomString())",
                                                               includeAll: true,
                                                               templateIds: [],
                                                               isGlobal: true,
                                                               projectIds: [],
                                                               isRequired: false,
                                                               format: .markdown,
                                                               hasExpected: false,
                                                               rows: .unspecified)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
            newCaseField.data.configs[0].options.hasExpected = true
            newCaseField.data.configs[0].options.rows = .five
        }

        return newCaseField
    }

    func newCaseFieldMultiselect(with properties: Properties) -> NewCaseField<NewCaseFieldMultiselectData> {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        // Multiselect will throw if `items` is empty.
        var newCaseField: NewCaseField<NewCaseFieldMultiselectData>
        do {
            newCaseField = try NewCaseField<NewCaseFieldMultiselectData>(description: nil,
                                                                         label: "Test Add: Multiselect",
                                                                         name: "quiztraintests_\(randomString())",
                                                                         includeAll: true,
                                                                         templateIds: [],
                                                                         isGlobal: true,
                                                                         projectIds: [],
                                                                         isRequired: false,
                                                                         items: ["A", "B", "C"])
        } catch {
            fatalError(error.localizedDescription)
        }

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseField.description = "Test Add: Description"
            newCaseField.includeAll = false // Must be false if templateIds is not empty.
            newCaseField.templateIds = [testProject.templates[0].id]
            newCaseField.data.configs[0].context.isGlobal = false // Must be false if projectIds is not empty.
            newCaseField.data.configs[0].context.projectIds = [testProject.project.id]
        }

        return newCaseField
    }

    func newConfiguration() -> NewConfiguration {
        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")
        return NewConfiguration(name: "Test Add: Configuration Name")
    }

    func newConfigurationGroup() -> NewConfigurationGroup {
        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")
        return NewConfigurationGroup(name: "Test Add: Configuration Group Name")
    }

    func newMilestone(with properties: Properties) -> NewMilestone {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newMilestone = NewMilestone(description: nil,
                                        dueOn: nil,
                                        name: "Test Add: Milestone Name",
                                        parentId: nil,
                                        startOn: nil)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            let now = Date()
            newMilestone.description = "Test Add: Milestone Description"
            newMilestone.dueOn = Date(timeInterval: 86400, since: now)
            newMilestone.parentId = nil // Caller can set if necessary.
            newMilestone.startOn = now
        }

        return newMilestone
    }

    func newPlan(with properties: Properties) -> NewPlan {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newPlan = NewPlan(description: nil,
                              entries: nil,
                              milestoneId: nil,
                              name: "Test Add: Plan Name")

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newPlan.description = "Test Add: Plan Description"
            newPlan.entries = []
            for _ in 0..<3 {
                let newPlanEntry = self.newPlanEntry(with: .requiredAndOptionalProperties)
                newPlan.entries?.append(newPlanEntry)
            }
            newPlan.milestoneId = testProject.milestones[0].id
        }

        return newPlan
    }

    func newPlanEntry(with properties: Properties) -> NewPlan.Entry {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        let suite = testProject.suites[0]

        var newPlanEntry = NewPlan.Entry(assignedtoId: nil,
                                         caseIds: nil,
                                         description: nil,
                                         includeAll: nil,
                                         name: nil,
                                         runs: nil,
                                         suiteId: suite.id)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:

            let suiteCaseIds = testProject.cases.filter { $0.suiteId == suite.id }

            newPlanEntry.assignedtoId = testProject.user.id
            newPlanEntry.caseIds = suiteCaseIds.compactMap { $0.id }
            newPlanEntry.description = "Test Add: Plan Entry Description"
            newPlanEntry.includeAll = false
            newPlanEntry.name = "Test Add: Plan Entry Name"
            newPlanEntry.runs = []

            var groupedConfigIds = [Int: [Int]]()
            for i in 0..<testProject.configurationGroups.count {
                let group = testProject.configurationGroups[i]
                let configIds = testProject.configurations.filter({ $0.groupId == group.id }).compactMap { $0.id }
                groupedConfigIds[i] = configIds
            }

            for i in 0..<objectCount {

                // One Configuration.id per ConfigurationGroup is allowed per
                // run. Here we add one configuration per group to each run.

                var configIds = [Int]()
                for (_, value) in groupedConfigIds {
                    configIds.append(value[i])
                }

                let suite = testProject.suites[i]
                let caseIds = testProject.cases.filter({ $0.suiteId == suite.id }).compactMap { $0.id }
                let milestone = testProject.milestones[i]

                var newPlanEntryRun = self.newPlanEntryRun()

                newPlanEntryRun.assignedtoId = testProject.user.id
                newPlanEntryRun.caseIds = caseIds
                newPlanEntryRun.configIds = configIds
                newPlanEntryRun.description = "Test Add: Plan.Entry.Run Description (\(configIds))"
                newPlanEntryRun.includeAll = false
                newPlanEntryRun.milestoneId = milestone.id
                newPlanEntryRun.name = "Test Add: Plan.Entry.Run Name (\(configIds))"
                newPlanEntryRun.suiteId = suite.id

                newPlanEntry.runs?.append(newPlanEntryRun)
            }
        }

        return newPlanEntry
    }

    /*
     Due to how NewPlan.Entry.Run's are influenced by NewPlan.Entry's, only nil
     values are returned for their properties.
     */
    func newPlanEntryRun() -> NewPlan.Entry.Run {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        return NewPlan.Entry.Run(assignedtoId: nil,
                                 caseIds: nil,
                                 configIds: nil,
                                 description: nil,
                                 includeAll: nil,
                                 milestoneId: nil,
                                 name: nil,
                                 suiteId: nil)
    }

    func newProject(with properties: Properties) -> NewProject {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newProject = NewProject(announcement: nil,
                                    name: "QuizTrainTests: Test Add: Project Name",
                                    showAnnouncement: false,
                                    suiteMode: .multipleSuites)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newProject.announcement = "QuizTrainTests: Test Add: Project Annoucement"
            newProject.showAnnouncement = true
        }

        return newProject
    }

    func newResult(with properties: Properties) -> NewResult {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newResult = NewResult(assignedtoId: nil,
                                  comment: nil,
                                  defects: nil,
                                  elapsed: nil,
                                  statusId: 1,
                                  version: nil,
                                  customFields: nil)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newResult.assignedtoId = testProject.user.id
            newResult.comment = "Test Add: Comment"
            newResult.defects = "Test Add: Defects"
            newResult.elapsed = "1m 30s"
            newResult.version = "INVALID"
            // data.customFields can be set by caller if necessary.
        }

        return newResult
    }

    func newCaseResults(with properties: Properties) -> NewCaseResults {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseResults = NewCaseResults(results: [])

        for _ in 0..<3 {
            newCaseResults.results.append(newCaseResultsResult(with: properties))
        }

        return newCaseResults
    }

    func newCaseResultsResult(with properties: Properties) -> NewCaseResults.Result {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newCaseResultsResult = NewCaseResults.Result(assignedtoId: nil,
                                                         caseId: testProject.cases[0].id,
                                                         comment: nil,
                                                         defects: nil,
                                                         elapsed: nil,
                                                         statusId: nil,
                                                         version: nil,
                                                         customFields: nil)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newCaseResultsResult.assignedtoId = testProject.user.id
            newCaseResultsResult.comment = "Test Add:  Comment"
            newCaseResultsResult.defects = "Test Add:  Defects"
            newCaseResultsResult.elapsed = "1m 30s"
            newCaseResultsResult.statusId = 1
            newCaseResultsResult.version = "INVALID"
            // customFields can be set by caller if necessary.
        }

        return newCaseResultsResult
    }

    func newTestResults(with properties: Properties) -> NewTestResults {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newTestResults = NewTestResults(results: [])

        for _ in 0..<3 {
            newTestResults.results.append(newTestResultsResult(with: properties))
        }

        return newTestResults
    }

    func newTestResultsResult(with properties: Properties) -> NewTestResults.Result {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newTestResultsResult = NewTestResults.Result(assignedtoId: nil,
                                                         comment: nil,
                                                         defects: nil,
                                                         elapsed: nil,
                                                         statusId: nil,
                                                         testId: testProject.tests[0].id,
                                                         version: nil,
                                                         customFields: nil)

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newTestResultsResult.assignedtoId = testProject.user.id
            newTestResultsResult.comment = "Test Add: Comment"
            newTestResultsResult.defects = "Test Add: Defects"
            newTestResultsResult.elapsed = "1m 30s"
            newTestResultsResult.statusId = 1
            newTestResultsResult.version = "INVALID"
            // customFields can be set by caller if necessary.
        }

        return newTestResultsResult
    }

    func newRun(with properties: Properties) -> NewRun {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newRun = NewRun(assignedtoId: nil,
                            caseIds: testProject.cases.compactMap { $0.id },
                            description: nil,
                            includeAll: false,
                            milestoneId: nil,
                            name: "Test Add: Run Name",
                            suiteId: nil)

        if testProject.project.suiteMode != .singleSuite {
            newRun.suiteId = testProject.suites[0].id
        }

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newRun.assignedtoId = testProject.user.id
            newRun.description = "Test Add: Run Description"
            newRun.milestoneId = testProject.milestones[0].id
        }

        return newRun
    }

    func newSection(with properties: Properties) -> NewSection {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newSection = NewSection(description: nil,
                                    name: "Test Add: Section Name",
                                    parentId: nil,
                                    suiteId: nil)

        if testProject.project.suiteMode != .singleSuite {
            newSection.suiteId = testProject.suites[0].id
        }

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newSection.description = "Test Add: Section Description"
            newSection.parentId = nil // Caller can set if necessary.
        }

        return newSection
    }

    func newSuite(with properties: Properties) -> NewSuite {

        precondition(testProject != nil, "The Test Project must be setup before invoking \(#function)")

        var newSuite = NewSuite(description: nil,
                                name: "Test Add: Suite Name")

        switch properties {
        case .requiredProperties:
            break
        case .requiredAndOptionalProperties:
            newSuite.description = "Test Add: Suite Description"
        }

        return newSuite
    }

    func updatePlanEntryRuns() -> UpdatePlanEntryRuns {
        return UpdatePlanEntryRuns(assignedtoId: testProject.user.id,
                                   caseIds: [testProject.cases[objectCount - 1].id],
                                   description: "Test Update: Plan.Entry Run Description",
                                   includeAll: false)
    }

}

// MARK: - Data Provider Helpers

extension ObjectAPITests {

    fileprivate func randomString(length: UInt = 8) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyz"
        let randomCharacters = (0..<length).map { _ in characters.randomElement()! }
        return String(randomCharacters)
    }

}

// MARK: - CaseField Helpers

extension ObjectAPITests {

    struct CaseFieldItemsConverter: ItemsConverter {
        typealias Item = String
    }

}

// MARK: - Object Tests

extension ObjectAPITests {

    // MARK: Case

    func testAddCase() {

        var newCase1 = newCase(with: .requiredProperties)
        newCase1.title += ": \(#function)"
        assertAddCase(newCase1, to: testProject.sections[0])

        var newCase2 = newCase(with: .requiredProperties)
        newCase2.title += ": \(#function)"
        assertAddCase(newCase(with: .requiredAndOptionalProperties), to: testProject.sections[0])
    }

    func testDeleteCase() {

        continueAfterFailure = false
        var newCase = self.newCase(with: .requiredAndOptionalProperties)
        newCase.title += ": \(#function)"
        guard let `case` = assertAddCase(newCase, to: testProject.sections[0]) else { return }
        continueAfterFailure = true

        assertDeleteCase(`case`)
    }

    func testGetCase() {

        continueAfterFailure = false
        var newCase = self.newCase(with: .requiredAndOptionalProperties)
        newCase.title += ": \(#function)"
        guard let `case` = assertAddCase(newCase, to: testProject.sections[0]) else { return }
        continueAfterFailure = true

        assertGetCase(`case`.id)
    }

    func testGetCases() {

        continueAfterFailure = false
        var newCase1 = newCase(with: .requiredProperties)
        var newCase2 = newCase(with: .requiredAndOptionalProperties)
        newCase1.title += ": \(#function)"
        newCase2.title += ": \(#function)"
        guard let case1 = assertAddCase(newCase1, to: testProject.sections[0]) else { return }
        guard let case2 = assertAddCase(newCase2, to: testProject.sections[0]) else { return }
        let addedCases = [case1, case2]
        continueAfterFailure = true

        // Unfiltered

        if let cases = assertGetCases(in: testProject.project, in: testProject.suites[0], in: testProject.sections[0], filteredBy: nil) {
            XCTAssertGreaterThanOrEqual(cases.count, addedCases.count)
            for addedCase in addedCases {
                XCTAssertEqual(cases.filter({ $0.id == addedCase.id }).count, 1, "Added Case \(addedCase.id) was not returned when getting all cases: \(cases)")
            }
        }

        // Filtered

        let priorityIds = [1, 2]
        let filters = [Filter(named: "priority_id", matching: priorityIds)]

        if let cases = assertGetCases(in: testProject.project, in: testProject.suites[0], in: testProject.sections[0], filteredBy: filters) {
            for `case` in cases {
                XCTAssertEqual(priorityIds.filter({ $0 == `case`.priorityId }).count, 1, "Case \(`case`.id) did not match filter for priorityIds: \(priorityIds)")
            }
        }
    }

    func testUpdateCase() {

        continueAfterFailure = false
        var newCase = self.newCase(with: .requiredAndOptionalProperties)
        newCase.title += ": \(#function)"
        guard var `case` = assertAddCase(newCase, to: testProject.sections[0]) else { return }
        continueAfterFailure = true

        `case`.estimate = "10m"
        `case`.milestoneId = nil // Marked as inactive for the project so unable to update.
        `case`.priorityId = 2
        `case`.refs = "RF-1001, RF-1002"
        `case`.templateId = testProject.templates[1].id
        `case`.title = "Test Update: Case Title: \(#function)"
        `case`.typeId = 2

        assertUpdateCase(`case`)
    }

    // MARK: CaseField

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddCheckboxCaseField() {

        var newCaseField = newCaseFieldCheckbox(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldCheckbox(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddDateCaseField() {

        var newCaseField = newCaseFieldDate(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldDate(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddDropdownCaseField() {

        var newCaseField = newCaseFieldDropdown(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldDropdown(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddIntegerCaseField() {

        var newCaseField = newCaseFieldInteger(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldInteger(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddMilestoneCaseField() {

        var newCaseField = newCaseFieldMilestone(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldMilestone(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddMultiselectCaseField() {

        var newCaseField = newCaseFieldMultiselect(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldMultiselect(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /**
     Disabled by default in all testing schemes since this requires manual
     deletion to cleanup.

     You can only have one CaseField of type NewCaseFieldType.steps across your
     entire TestRail instance. If one of that type already exists you must
     delete it to run this test successfully (not recommended on production
     since deleting it will destroy all data associated with it). If you run
     this test and a CaseField of type NewCaseFieldType.steps already exists
     then the API will return an error code 400 and this test will fail.
     */
    func testAddStepsCaseField() {

        // Uncomment one or the other.

        /*
        var newCaseField = newCaseFieldSteps(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
        */

        var newCaseField = newCaseFieldSteps(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddStringCaseField() {

        var newCaseField = newCaseFieldString(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldString(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddTextCaseField() {

        var newCaseField = newCaseFieldText(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldText(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddURLCaseField() {

        var newCaseField = newCaseFieldURL(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldURL(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    /// Disabled by default in all testing schemes since this requires manual deletion to cleanup.
    func testAddUserCaseField() {

        var newCaseField = newCaseFieldUser(with: .requiredProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)

        newCaseField = newCaseFieldUser(with: .requiredAndOptionalProperties)
        newCaseField.label = "\(#function)"
        assertAddCaseField(newCaseField)
    }

    func testGetCaseFields() {
        assertGetCaseFields()
    }

    // MARK: CaseType

    func testGetCaseTypes() {
        assertGetCaseTypes()
    }

    // MARK: Configuration

    func testAddConfiguration() {
        var newConfiguration = self.newConfiguration()
        newConfiguration.name += ": \(#function)"
        assertAddConfiguration(newConfiguration, to: testProject.configurationGroups[0])
    }

    func testDeleteConfiguration() {

        continueAfterFailure = false
        var newConfiguration = self.newConfiguration()
        newConfiguration.name += ": \(#function)"
        guard let configuration = assertAddConfiguration(newConfiguration, to: testProject.configurationGroups[0]) else { return }
        continueAfterFailure = true

        assertDeleteConfiguration(configuration)
    }

    func testUpdateConfiguration() {

        continueAfterFailure = false
        var newConfiguration = self.newConfiguration()
        newConfiguration.name += ": \(#function)"
        guard var configuration = assertAddConfiguration(newConfiguration, to: testProject.configurationGroups[0]) else { return }
        continueAfterFailure = true

        configuration.name = "Test Update: Configuration Name: \(#function)"

        assertUpdateConfiguration(configuration)
    }

    // MARK: ConfigurationGroup

    func testAddConfigurationGroup() {
        var newConfigurationGroup = self.newConfigurationGroup()
        newConfigurationGroup.name += ": \(#function)"
        assertAddConfigurationGroup(newConfigurationGroup, to: testProject.project)
    }

    func testDeleteConfigurationGroup() {

        continueAfterFailure = false
        var newConfigurationGroup = self.newConfigurationGroup()
        newConfigurationGroup.name += ": \(#function)"
        guard let configurationGroup = assertAddConfigurationGroup(newConfigurationGroup, to: testProject.project) else { return }
        continueAfterFailure = true

        assertDeleteConfigurationGroup(configurationGroup)
    }

    func testGetConfigurationGroups() {
        if let configurationGroups = assertGetConfigurationGroups() {
            for configurationGroup in testProject.configurationGroups {
                XCTAssertEqual(configurationGroups.filter({ $0.id == configurationGroup.id }).count, 1, "ConfigurationGroup \(configurationGroup.id) was not returned when getting all configuration group's in all projects: \(configurationGroups)")
            }
        }
    }

    func testGetConfigurationGroupsInProject() {
        if let configurationGroups = assertGetConfigurationGroups(in: testProject.project) {
            for configurationGroup in testProject.configurationGroups {
                XCTAssertEqual(configurationGroups.filter({ $0.id == configurationGroup.id }).count, 1, "ConfigurationGroup \(configurationGroup.id) was not returned when getting all configuration group's in project \(testProject.project.id): \(configurationGroups)")
            }
        }
    }

    func testUpdateConfigurationGroup() {

        continueAfterFailure = false
        var newConfigurationGroup = self.newConfigurationGroup()
        newConfigurationGroup.name += ": \(#function)"
        guard var configurationGroup = assertAddConfigurationGroup(newConfigurationGroup, to: testProject.project) else { return }
        continueAfterFailure = true

        configurationGroup.name = "Test Update: ConfigurationGroup Name"

        assertUpdateConfigurationGroup(configurationGroup)
    }

    // MARK: Milestone

    func testAddMilestone() {
        var newMilestone1 = newMilestone(with: .requiredProperties)
        var newMilestone2 = newMilestone(with: .requiredAndOptionalProperties)
        newMilestone1.name += ": \(#function)"
        newMilestone2.name += ": \(#function)"
        assertAddMilestone(newMilestone1, to: testProject.project)
        assertAddMilestone(newMilestone2, to: testProject.project)
    }

    func testDeleteMilestone() {

        continueAfterFailure = false
        var newMilestone = self.newMilestone(with: .requiredAndOptionalProperties)
        newMilestone.name += ": \(#function)"
        guard let milestone = assertAddMilestone(newMilestone, to: testProject.project) else { return }
        continueAfterFailure = true

        assertDeleteMilestone(milestone)
    }

    func testGetMilestone() {
        assertGetMilestone(testProject.milestones[0].id)
    }

    func testGetMilestones() {

        // Unfiltered

        if let milestones = assertGetMilestones(in: testProject.project, filteredBy: nil) {
            XCTAssertGreaterThanOrEqual(milestones.count, testProject.milestones.count)
            for milestone in testProject.milestones {
                XCTAssertEqual(milestones.filter({ $0.id == milestone.id }).count, 1, "Milestone \(milestone.id) was not returned when getting all milestones: \(milestones)")
            }
        }

        // Filtered

        let filters = [Filter(named: "is_completed", matching: false)]

        if let milestones = assertGetMilestones(in: testProject.project, filteredBy: filters) {
            for milestone in milestones {
                XCTAssertEqual(milestone.isCompleted, false)
            }
        }
    }

    func testUpdateMilestone() {

        continueAfterFailure = false
        var newMilestone1 = newMilestone(with: .requiredProperties)
        var newMilestone2 = newMilestone(with: .requiredProperties)
        var newMilestone3 = newMilestone(with: .requiredProperties)
        newMilestone1.name += ": \(#function)"
        newMilestone2.name += ": \(#function)"
        newMilestone3.name += ": \(#function)"
        guard var milestone1 = assertAddMilestone(newMilestone1, to: testProject.project) else { return }
        guard var milestone2 = assertAddMilestone(newMilestone2, to: testProject.project) else { return }
        guard var milestone3 = assertAddMilestone(newMilestone3, to: testProject.project) else { return }
        continueAfterFailure = true

        /*
         - A Milestone that isStarted cannot have a startOn date.
         - A Milestone with a startOn data cannot have isStarted set to true.

         If those rules are not followed TestRail will return a 400 error:

         "Milestone start date given but not marked as scheduled/upcoming."
         */

        // Not Started

        let date1 = Date()
        milestone1.description = "Test Update: Milestone Description 1"
        milestone1.dueOn = Date(timeInterval: 1000, since: date1)
        milestone1.isCompleted = false
        milestone1.isStarted = false // Must be false since startOn is not nil.
        milestone1.name = "Test Update: Milestone Name 1: \(#function)"
        milestone1.parentId = testProject.milestones[0].id
        milestone1.startOn = date1

        assertUpdateMilestone(milestone1)

        // Started

        let date2 = Date()
        milestone2.description = "Test Update: Milestone Description 2"
        milestone2.dueOn = Date(timeInterval: 1000, since: date2)
        milestone2.isCompleted = false
        milestone2.isStarted = true
        milestone2.name = "Test Update: Milestone Name 2: \(#function)"
        milestone2.parentId = testProject.milestones[0].id
        milestone2.startOn = nil // Must be nil since isStarted is true.

        assertUpdateMilestone(milestone2)

        // Completed

        let date3 = Date()
        milestone3.description = "Test Update: Milestone Description 3"
        milestone3.dueOn = Date(timeInterval: 1000, since: date3)
        milestone3.isCompleted = true
        milestone3.isStarted = true
        milestone3.name = "Test Update: Milestone Name 3: \(#function)"
        milestone3.parentId = testProject.milestones[0].id
        milestone3.startOn = nil

        assertUpdateMilestone(milestone3)
    }

    // MARK: Plan

    func testAddPlan() {

        var newPlan1 = self.newPlan(with: .requiredProperties)
        newPlan1.name += ": \(#function)"
        assertAddPlan(newPlan1, to: testProject.project)

        var newPlan2 = self.newPlan(with: .requiredAndOptionalProperties)
        newPlan2.name += ": \(#function)"
        assertAddPlan(newPlan2, to: testProject.project)
    }

    func testClosePlan() {

        continueAfterFailure = false
        var newPlan = self.newPlan(with: .requiredAndOptionalProperties)
        newPlan.name += ": \(#function)"
        guard let plan = assertAddPlan(newPlan, to: testProject.project) else { return }
        continueAfterFailure = true

        assertClosePlan(plan)
    }

    func testDeletePlan() {

        continueAfterFailure = false
        var newPlan = self.newPlan(with: .requiredAndOptionalProperties)
        newPlan.name += ": \(#function)"
        guard let plan = assertAddPlan(newPlan, to: testProject.project) else { return }
        continueAfterFailure = true

        assertDeletePlan(plan)
    }

    func testGetPlan() {
        assertGetPlan(testProject.plans[0].id)
    }

    func testGetPlans() {

        // Unfiltered

        if let plans = assertGetPlans(in: testProject.project, filteredBy: nil) {
            for plan in testProject.plans {
                XCTAssertEqual(plans.filter({ $0.id == plan.id }).count, 1, "Plan \(plan.id) was not returned when getting all plans: \(plans)")
            }
        }

        // Filtered

        // The limit/offset filters can be combined to paginate a request.
        let limit = 1
        let filters = [Filter(named: "limit", matching: limit),
                       Filter(named: "offset", matching: 1)]

        if let plans = assertGetPlans(in: testProject.project, filteredBy: filters) {
            XCTAssertLessThanOrEqual(plans.count, limit)
        }
    }

    func testUpdatePlan() {

        continueAfterFailure = false
        var newPlan = NewPlan(description: "Test Add: Plan Description", entries: nil, milestoneId: nil, name: "Test Add: Plan Name")
        newPlan.name += ": \(#function)"
        guard var plan = assertAddPlan(newPlan, to: testProject.project) else { return }
        continueAfterFailure = true

        plan.description = "Test Update: Plan Description"
        plan.milestoneId = testProject.milestones[0].id
        plan.name = "Test Update: Plan Name: \(#function)"

        assertUpdatePlan(plan)
    }

    // MARK: Plan.Entry

    func testAddPlanEntry() {
        var newPlanEntry1 = newPlanEntry(with: .requiredProperties)
        var newPlanEntry2 = newPlanEntry(with: .requiredAndOptionalProperties)
        newPlanEntry1.name? += ": \(#function)"
        newPlanEntry2.name? += ": \(#function)"
        assertAddPlanEntry(newPlanEntry1, to: testProject.plans[0])
        assertAddPlanEntry(newPlanEntry2, to: testProject.plans[1])
    }

    func testDeletePlanEntry() {

        continueAfterFailure = false
        let plan = testProject.plans[0]
        var newPlanEntry = self.newPlanEntry(with: .requiredAndOptionalProperties)
        newPlanEntry.name? += ": \(#function)"
        guard let planEntry = assertAddPlanEntry(newPlanEntry, to: plan) else { return }
        continueAfterFailure = true

        assertDeletePlanEntry(planEntry, from: plan)
    }

    func testUpdatePlanEntry() {

        continueAfterFailure = false
        let plan = testProject.plans[0]
        var newPlanEntry1 = newPlanEntry(with: .requiredAndOptionalProperties)
        var newPlanEntry2 = newPlanEntry(with: .requiredAndOptionalProperties)
        newPlanEntry1.name? += ": \(#function)"
        newPlanEntry2.name? += ": \(#function)"
        guard let planEntry1 = assertAddPlanEntry(newPlanEntry1, to: plan) else { return }
        guard let planEntry2 = assertAddPlanEntry(newPlanEntry2, to: plan) else { return }
        continueAfterFailure = true

        // Plan.Entry Only

        assertUpdatePlanEntry(planEntry1, in: plan)

        // Plan.Entry and Runs

        // NOTE: This does not appear to change anything on TestRail even though
        // the API call succeeds.

        var updatedRuns = updatePlanEntryRuns()
        updatedRuns.description? += ": \(#function)"

        assertUpdatePlanEntry(planEntry2, in: plan, with: updatedRuns)
    }

    // MARK: Priority

    func testGetPriorities() {
        assertGetPriorities()
    }

    // MARK: Project

    func testAddProject() {

        var newProject1 = newProject(with: .requiredProperties)
        newProject1.name += ": \(#function)"
        if let project = assertAddProject(newProject1) {
            assertDeleteProject(project)
        }

        var newProject2 = newProject(with: .requiredAndOptionalProperties)
        newProject2.name += ": \(#function)"
        if let project = assertAddProject(newProject2) {
            assertDeleteProject(project)
        }
    }

    func testDeleteProject() {

        continueAfterFailure = false
        var newProject = self.newProject(with: .requiredAndOptionalProperties)
        newProject.name += ": \(#function)"
        guard let project = assertAddProject(newProject) else { return }
        continueAfterFailure = true

        assertDeleteProject(project)
    }

    func testGetProject() {
        assertGetProject(testProject.project.id)
    }

    func testGetProjects() {
        assertGetProjects()
    }

    func testUpdateProject() {

        continueAfterFailure = false
        var newProject = self.newProject(with: .requiredAndOptionalProperties)
        newProject.name += ": \(#function)"
        guard var project = assertAddProject(newProject) else { return }
        continueAfterFailure = true

        defer {
            continueAfterFailure = true
            assertDeleteProject(project) // Cleanup when complete.
        }

        project.announcement = "QuizTrainTests: Test Update: Project Annoucement"
        project.isCompleted = true
        project.name = "QuizTrainTests: Test Update: Project Name"
        project.showAnnouncement = true
        // Updating project.suiteMode does not appear to work, so that is ommitted from this test.

        assertUpdateProject(project)
    }

    // MARK: Result

    func testAddResult() {
        let newResult1 = newResult(with: .requiredProperties)
        let newResult2 = newResult(with: .requiredAndOptionalProperties)
        assertAddResult(newResult1, to: testProject.tests[0])
        assertAddResult(newResult2, to: testProject.tests[0])
    }

    func testAddResultForCase() {
        let newResult1 = newResult(with: .requiredProperties)
        let newResult2 = newResult(with: .requiredAndOptionalProperties)
        assertAddResultForCase(newResult1, to: testProject.runs[0], to: testProject.cases[0])
        assertAddResultForCase(newResult2, to: testProject.runs[0], to: testProject.cases[0])
    }

    func testAddResults() {

        // AssignedtoId

        var newTestResults = self.newTestResults(with: .requiredProperties)

        newTestResults.results = newTestResults.results.map {
            var result = $0
            result.assignedtoId = testProject.user.id
            return result
        }

        XCTAssertTrue(newTestResults.isValid)
        assertAddResults(newTestResults, to: testProject.runs[0])

        // Comment

        newTestResults = self.newTestResults(with: .requiredProperties)

        newTestResults.results = newTestResults.results.map {
            var result = $0
            result.comment = "Test Add: Test Comment"
            return result
        }

        XCTAssertTrue(newTestResults.isValid)
        assertAddResults(newTestResults, to: testProject.runs[0])

        // StatusId

        newTestResults = self.newTestResults(with: .requiredProperties)

        newTestResults.results = newTestResults.results.map {
            var result = $0
            result.statusId = 1
            return result
        }

        XCTAssertTrue(newTestResults.isValid)
        assertAddResults(newTestResults, to: testProject.runs[0])

        // All of the above.

        newTestResults = self.newTestResults(with: .requiredAndOptionalProperties)

        XCTAssertTrue(newTestResults.isValid)
        assertAddResults(newTestResults, to: testProject.runs[0])
    }

    func testAddResultsForCases() {

        // AssignedtoId

        var newCaseResults = self.newCaseResults(with: .requiredProperties)

        newCaseResults.results = newCaseResults.results.map {
            var result = $0
            result.assignedtoId = testProject.user.id
            return result
        }

        XCTAssertTrue(newCaseResults.isValid)
        assertAddResultsForCases(newCaseResults, to: testProject.runs[0])

        // Comment

        newCaseResults = self.newCaseResults(with: .requiredProperties)

        newCaseResults.results = newCaseResults.results.map {
            var result = $0
            result.comment = "Test Add: Test Comment"
            return result
        }

        XCTAssertTrue(newCaseResults.isValid)
        assertAddResultsForCases(newCaseResults, to: testProject.runs[0])

        // StatusId

        newCaseResults = self.newCaseResults(with: .requiredProperties)

        newCaseResults.results = newCaseResults.results.map {
            var result = $0
            result.statusId = 1
            return result
        }

        XCTAssertTrue(newCaseResults.isValid)
        assertAddResultsForCases(newCaseResults, to: testProject.runs[0])

        // All of the above.

        newCaseResults = self.newCaseResults(with: .requiredAndOptionalProperties)

        XCTAssertTrue(newCaseResults.isValid)
        assertAddResultsForCases(newCaseResults, to: testProject.runs[0])
    }

    func testGetResultsForTest() {
        assertGetResultsForTest(testProject.tests[0])
    }

    func testGetResultsForCase() {

        // Unfiltered

        assertGetResultsForCase(testProject.cases[0], in: testProject.runs[0], filteredBy: nil)

        // Filtered

        let statusId = 1
        let filters = [Filter(named: "status_id", matching: statusId)]

        if let results = assertGetResultsForCase(testProject.cases[0], in: testProject.runs[0], filteredBy: filters) {
            for result in results {
                XCTAssertEqual(result.statusId, statusId, "Result \(result.id) did not match filter for status_id: \(statusId)")
            }
        }
    }

    func testGetResultsForRun() {

        // Unfiltered

        assertGetResultsForRun(testProject.runs[0], filteredBy: nil)

        // Filtered

        let statusId = 1
        let filters = [Filter(named: "status_id", matching: statusId)]

        if let results = assertGetResultsForRun(testProject.runs[0], filteredBy: filters) {
            for result in results {
                XCTAssertEqual(result.statusId, statusId, "Result \(result.id) did not match filter for status_id: \(statusId)")
            }
        }
    }

    // MARK: ResultField

    func testGetResultFields() {
        assertGetResultFields()
    }

    // MARK: Run

    func testAddRun() {
        var newRun1 = newRun(with: .requiredProperties)
        var newRun2 = newRun(with: .requiredAndOptionalProperties)
        newRun1.name += ": \(#function)"
        newRun2.name += ": \(#function)"
        assertAddRun(newRun1, to: testProject.project)
        assertAddRun(newRun2, to: testProject.project)
    }

    func testCloseRun() {

        continueAfterFailure = false
        var newRun = self.newRun(with: .requiredAndOptionalProperties)
        newRun.name += ": \(#function)"
        guard let run = assertAddRun(newRun, to: testProject.project) else { return }
        continueAfterFailure = true

        assertCloseRun(run)
    }

    func testDeleteRun() {

        continueAfterFailure = false
        var newRun = self.newRun(with: .requiredAndOptionalProperties)
        newRun.name += ": \(#function)"
        guard let run = assertAddRun(newRun, to: testProject.project) else { return }
        continueAfterFailure = true

        assertDeleteRun(run)
    }

    func testGetRun() {
        assertGetRun(testProject.runs[0].id)
    }

    func testGetRuns() {

        // Unfiltered

        assertGetRuns(in: testProject.project, filteredBy: nil)

        // Filtered

        let isCompleted = false
        let filters = [Filter(named: "is_completed", matching: isCompleted)]

        if let runs = assertGetRuns(in: testProject.project, filteredBy: filters) {
            for run in runs {
                XCTAssertEqual(run.isCompleted, isCompleted)
            }
        }
    }

    func testUpdateRun() {

        continueAfterFailure = false
        var newRun = self.newRun(with: .requiredAndOptionalProperties)
        newRun.name += ": \(#function)"
        guard var run = assertAddRun(newRun, to: testProject.project) else { return }
        continueAfterFailure = true

        run.description = "Test Update: Run Description"
        run.includeAll = true
        run.milestoneId = testProject.milestones[1].id
        run.name = "Test Update: Run Name: \(#function)"

        assertUpdateRun(run)
    }

    // MARK: Section

    func testAddSection() {
        var newSection1 = self.newSection(with: .requiredProperties)
        var newSection2 = self.newSection(with: .requiredAndOptionalProperties)
        newSection1.name += ": \(#function)"
        newSection2.name += ": \(#function)"
        assertAddSection(newSection1, to: testProject.project)
        assertAddSection(newSection2, to: testProject.project)
    }

    func testDeleteSection() {

        continueAfterFailure = false
        var newSection = self.newSection(with: .requiredAndOptionalProperties)
        newSection.name += ": \(#function)"
        guard let section = assertAddSection(newSection, to: testProject.project) else { return }
        continueAfterFailure = true

        assertDeleteSection(section)
    }

    func testGetSection() {
        assertGetSection(testProject.sections[0].id)
    }

    func testGetSections() {
        if let sections = assertGetSections(in: testProject.project, in: testProject.suites[0]) {
            for section in sections {
                XCTAssertEqual(section.suiteId, testProject.suites[0].id)
            }
        }
    }

    func testUpdateSection() {

        continueAfterFailure = false
        var newSection = self.newSection(with: .requiredAndOptionalProperties)
        newSection.name += ": \(#function)"
        guard var section = assertAddSection(newSection, to: testProject.project) else { return }
        continueAfterFailure = true

        section.description = "Section Description - Updated"
        section.name = "Section Name - Updated: \(#function)"

        assertUpdateSection(section)
    }

    // MARK: Status

    func testGetStatuses() {
        assertGetStatuses()
    }

    // MARK: Suite

    func testAddSuite() {
        var newSuite1 = newSuite(with: .requiredProperties)
        var newSuite2 = newSuite(with: .requiredAndOptionalProperties)
        newSuite1.name += ": \(#function)"
        newSuite2.name += ": \(#function)"
        assertAddSuite(newSuite1, to: testProject.project)
        assertAddSuite(newSuite2, to: testProject.project)
    }

    func testDeleteSuite() {

        continueAfterFailure = false
        var newSuite = self.newSuite(with: .requiredAndOptionalProperties)
        newSuite.name += ": \(#function)"
        guard let suite = assertAddSuite(newSuite, to: testProject.project) else { return }
        continueAfterFailure = true

        assertDeleteSuite(suite)
    }

    func testGetSuite() {
        assertGetSuite(testProject.suites[0].id)
    }

    func testGetSuites() {
        if let suites = assertGetSuites(in: testProject.project) {
            for suite in testProject.suites {
                XCTAssertEqual(suites.filter({ $0.id == suite.id }).count, 1, "Suite \(suite.id) was not returned when getting all suite's: \(suites)")
            }
        }
    }

    func testUpdateSuite() {

        continueAfterFailure = false
        var newSuite = self.newSuite(with: .requiredAndOptionalProperties)
        newSuite.name += ": \(#function)"
        guard var suite = assertAddSuite(newSuite, to: testProject.project) else { return }
        continueAfterFailure = true

        suite.description = "Test Update: Suite Description"
        suite.name = "Test Update: Suite Name"

        assertUpdateSuite(suite)
    }

    // MARK: Template

    func testGetTemplates() {
        assertGetTemplates()
    }

    func testGetTemplatesInProject() {
        assertGetTemplates(in: testProject.project)
    }

    // MARK: Test

    func testGetTest() {
        assertGetTest(testProject.tests[0].id)
    }

    func testGetTests() {

        // Unfiltered

        assertGetTests(in: testProject.runs[0], filteredBy: nil)

        // Filtered

        let statusId = 1
        let filters = [Filter(named: "status_id", matching: statusId)]

        if let tests = assertGetTests(in: testProject.runs[0], filteredBy: filters) {
            for test in tests {
                XCTAssertEqual(test.statusId, statusId)
            }
        }
    }

    // MARK: User

    func testGetUser() {

        continueAfterFailure = false
        guard let user = assertGetUsers(projectId: testProject.project.id)?.first else { return }
        continueAfterFailure = true

        assertGetUser(user.id)
    }

    func testGetUserByEmail() {

        continueAfterFailure = false
        guard let user = assertGetUsers(projectId: testProject.project.id)?.first else { return }
        continueAfterFailure = true

        assertGetUserByEmail(user.email)
    }

    func testGetUsers() {
        if let users = assertGetUsers(projectId: testProject.project.id) {
            XCTAssertEqual(users.filter({ $0.email == objectAPI.api.username }).count, 1, "User \(objectAPI.api.username) was not returned when getting all users: \(users)")
        }
    }

}

// MARK: - Object Matching Tests

extension ObjectAPITests {

    // MARK: Case

    func testGetCaseTypeMatchingId() {

        continueAfterFailure = false
        guard let caseTypes = assertGetCaseTypes() else { return }
        XCTAssertGreaterThan(caseTypes.count, 0, "This test cannot continue because there are no CaseType's.")
        continueAfterFailure = true

        guard let randomCaseType = caseTypes.randomElement else { return }

        assertGetCaseTypeMatchingId(randomCaseType.id)
    }

    // MARK: ConfigurationGroup

    func testGetConfigurationGroupMatchingId() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.configurationGroups.count, 0, "This test cannot continue because there are no ConfigurationGroup's.")
        continueAfterFailure = true

        guard let randomConfigurationGroup = testProject.configurationGroups.randomElement else { return }

        assertGetConfigurationGroupMatchingId(randomConfigurationGroup.id)
    }

    // MARK: Priority

    func testGetPriorityMatchingId() {

        continueAfterFailure = false
        guard let priorities = assertGetPriorities() else { return }
        XCTAssertGreaterThan(priorities.count, 0, "This test cannot continue because there are no Priorities.")
        continueAfterFailure = true

        guard let randomPriority = priorities.randomElement else { return }

        assertGetPriorityMatchingId(randomPriority.id)
    }

    // MARK: Status

    func testGetStatusMatchingId() {

        continueAfterFailure = false
        guard let statuses = assertGetStatuses() else { return }
        XCTAssertGreaterThan(statuses.count, 0, "This test cannot continue because there are no Statuses.")
        continueAfterFailure = true

        guard let randomStatus = statuses.randomElement else { return }

        assertGetStatusMatchingId(randomStatus.id)
    }

    // MARK: Template

    func testGetTemplateMatchingId() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.templates.count, 0, "This test cannot continue because there are no Templates.")
        continueAfterFailure = true

        guard let randomTemplate = testProject.templates.randomElement else { return }

        assertGetTemplateMatchingId(randomTemplate.id)
    }

    func testGetTemplatesMatchingIds() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.templates.count, 0, "This test cannot continue because there are no Templates.")
        continueAfterFailure = true

        // Pick up to 3 template ids randomly.

        var allTemplates = testProject.templates
        var randomTemplates = [Template]()

        if allTemplates.count > 2 {
            for _ in 0..<3 {
                let randomIndex = Int(arc4random_uniform(UInt32(allTemplates.count)))
                randomTemplates.append(allTemplates[randomIndex])
                allTemplates.remove(at: randomIndex)
            }
        } else {
            randomTemplates.append(contentsOf: allTemplates)
        }

        let randomTemplateIds = randomTemplates.compactMap { $0.id }

        assertGetTemplatesMatchingIds(randomTemplateIds)
    }

}

// MARK: - Object Forward Relationship Tests

extension ObjectAPITests {

    // MARK: Case

    func testGetCaseToCreatedByRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.cases.count, 0, "This test cannot continue because there are no Cases.")
        continueAfterFailure = true

        for `case` in testProject.cases {
            assertGetCaseToCreatedByRelationship(`case`)
            assertGetCaseToCreatedByRelationship(`case`, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetCaseToMilestoneRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.cases.count, 0, "This test cannot continue because there are no Cases.")
        continueAfterFailure = true

        for `case` in testProject.cases {
            assertGetCaseToMilestoneRelationship(`case`)
            assertGetCaseToMilestoneRelationship(`case`, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetCaseToPriorityRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.cases.count, 0, "This test cannot continue because there are no Cases.")
        continueAfterFailure = true

        for `case` in testProject.cases {
            assertGetCaseToPriorityRelationship(`case`)
            assertGetCaseToPriorityRelationship(`case`, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetCaseToSectionRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.cases.count, 0, "This test cannot continue because there are no Cases.")
        continueAfterFailure = true

        for `case` in testProject.cases {
            assertGetCaseToSectionRelationship(`case`)
            assertGetCaseToSectionRelationship(`case`, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetCaseToSuiteRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.cases.count, 0, "This test cannot continue because there are no Cases.")
        continueAfterFailure = true

        for `case` in testProject.cases {
            assertGetCaseToSuiteRelationship(`case`)
            assertGetCaseToSuiteRelationship(`case`, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetCaseToTemplateRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.cases.count, 0, "This test cannot continue because there are no Cases.")
        continueAfterFailure = true

        for `case` in testProject.cases {
            assertGetCaseToTemplateRelationship(`case`)
            assertGetCaseToTemplateRelationship(`case`, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetCaseToTypeRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.cases.count, 0, "This test cannot continue because there are no Cases.")
        continueAfterFailure = true

        for `case` in testProject.cases {
            assertGetCaseToTypeRelationship(`case`)
            assertGetCaseToTypeRelationship(`case`, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetCaseToUpdatedByRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.cases.count, 0, "This test cannot continue because there are no Cases.")
        continueAfterFailure = true

        for `case` in testProject.cases {
            assertGetCaseToUpdatedByRelationship(`case`)
            assertGetCaseToUpdatedByRelationship(`case`, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: CaseField

    func testGetCaseFieldToTemplatesRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.caseFields.count, 0, "This test cannot continue because there are no CaseFields.")
        continueAfterFailure = true

        for caseField in testProject.caseFields {
            assertGetCaseFieldToTemplatesRelationship(caseField)
            assertGetCaseFieldToTemplatesRelationship(caseField, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: CaseField.Config

    func testGetCaseFieldConfigToAccessibleProjectsRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.caseFields.count, 0, "This test cannot continue because there are no CaseFields.")
        continueAfterFailure = true

        for caseField in testProject.caseFields {
            for config in caseField.configs {
                assertGetConfigToAccessibleProjectsRelationship(config)
                assertGetConfigToAccessibleProjectsRelationship(config, usingObjectToRelationshipMethod: true)
            }
        }
    }

    func testGetCaseFieldConfigToProjectsRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.caseFields.count, 0, "This test cannot continue because there are no CaseFields.")
        continueAfterFailure = true

        for caseField in testProject.caseFields {
            for config in caseField.configs {
                assertGetConfigToProjectsRelationship(config)
                assertGetConfigToProjectsRelationship(config, usingObjectToRelationshipMethod: true)
            }
        }
    }

    // MARK: Configuration

    func testGetConfigurationToConfigurationGroupRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.configurations.count, 0, "This test cannot continue because there are no Configurations.")
        continueAfterFailure = true

        for configuration in testProject.configurations {
            assertGetConfigurationToConfigurationGroupRelationship(configuration)
            assertGetConfigurationToConfigurationGroupRelationship(configuration, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: ConfigurationGroup

    func testGetConfigurationGroupToProjectRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.configurationGroups.count, 0, "This test cannot continue because there are no ConfigurationGroups.")
        continueAfterFailure = true

        for configurationGroup in testProject.configurationGroups {
            assertGetConfigurationGroupToProjectRelationship(configurationGroup)
            assertGetConfigurationGroupToProjectRelationship(configurationGroup, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: Milestone

    func testGetMilestoneToParentRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.milestones.count, 0, "This test cannot continue because there are no Milestones.")
        continueAfterFailure = true

        for milestone in testProject.milestones {
            assertGetMilestoneToParentRelationship(milestone)
            assertGetMilestoneToParentRelationship(milestone, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetMilestoneToProjectRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.milestones.count, 0, "This test cannot continue because there are no Milestones.")
        continueAfterFailure = true

        for milestone in testProject.milestones {
            assertGetMilestoneToProjectRelationship(milestone)
            assertGetMilestoneToProjectRelationship(milestone, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: Plan

    func testGetPlanToAssignedtoRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.plans.count, 0, "This test cannot continue because there are no Plans.")
        continueAfterFailure = true

        for plan in testProject.plans {
            assertGetPlanToAssignedtoRelationship(plan)
            assertGetPlanToAssignedtoRelationship(plan, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetPlanToCreatedByRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.plans.count, 0, "This test cannot continue because there are no Plans.")
        continueAfterFailure = true

        for plan in testProject.plans {
            assertGetPlanToCreatedByRelationship(plan)
            assertGetPlanToCreatedByRelationship(plan, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetPlanToMilestoneRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.plans.count, 0, "This test cannot continue because there are no Plans.")
        continueAfterFailure = true

        for plan in testProject.plans {
            assertGetPlanToMilestoneRelationship(plan)
            assertGetPlanToMilestoneRelationship(plan, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetPlanToProjectRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.plans.count, 0, "This test cannot continue because there are no Plans.")
        continueAfterFailure = true

        for plan in testProject.plans {
            assertGetPlanToProjectRelationship(plan)
            assertGetPlanToProjectRelationship(plan, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: Plan.Entry

    func testGetPlanEntryToSuiteRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.plans.count, 0, "This test cannot continue because there are no Plans.")
        continueAfterFailure = true

        for plan in testProject.plans {
            if let planEntries = plan.entries {
                for planEntry in planEntries {
                    assertGetPlanEntryToSuiteRelationship(planEntry)
                    assertGetPlanEntryToSuiteRelationship(planEntry, usingObjectToRelationshipMethod: true)
                }
            }
        }
    }

    // MARK: Result

    func testGetResultToAssignedtoRelationship() {

        continueAfterFailure = false
        let newTestResults = self.newTestResults(with: .requiredAndOptionalProperties)
        guard let results = assertAddResults(newTestResults, to: testProject.runs[0]) else { return }
        continueAfterFailure = true

        for result in results {
            assertGetResultToAssignedtoRelationship(result)
            assertGetResultToAssignedtoRelationship(result, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetResultToCreatedByRelationship() {

        continueAfterFailure = false
        let newTestResults = self.newTestResults(with: .requiredAndOptionalProperties)
        guard let results = assertAddResults(newTestResults, to: testProject.runs[0]) else { return }
        continueAfterFailure = true

        for result in results {
            assertGetResultToCreatedByRelationship(result)
            assertGetResultToCreatedByRelationship(result, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetResultToStatusRelationship() {

        continueAfterFailure = false
        let newTestResults = self.newTestResults(with: .requiredAndOptionalProperties)
        guard let results = assertAddResults(newTestResults, to: testProject.runs[0]) else { return }
        continueAfterFailure = true

        for result in results {
            assertGetResultToStatusRelationship(result)
            assertGetResultToStatusRelationship(result, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetResultToTestRelationship() {

        continueAfterFailure = false
        let newTestResults = self.newTestResults(with: .requiredAndOptionalProperties)
        guard let results = assertAddResults(newTestResults, to: testProject.runs[0]) else { return }
        continueAfterFailure = true

        for result in results {
            assertGetResultToTestRelationship(result)
            assertGetResultToTestRelationship(result, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: ResultField

    func testGetResultFieldToTemplatesRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.resultFields.count, 0, "This test cannot continue because there are no ResultFields.")
        continueAfterFailure = true

        for resultField in testProject.resultFields {
            assertGetResultFieldToTemplatesRelationship(resultField)
            assertGetResultFieldToTemplatesRelationship(resultField, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: ResultField.Config

    func testGetResultFieldConfigToAccessibleProjectsRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.resultFields.count, 0, "This test cannot continue because there are no CaseFields.")
        continueAfterFailure = true

        for resultField in testProject.resultFields {
            for config in resultField.configs {
                assertGetConfigToAccessibleProjectsRelationship(config)
                assertGetConfigToAccessibleProjectsRelationship(config, usingObjectToRelationshipMethod: true)
            }
        }
    }

    func testGetResultFieldConfigToProjectsRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.resultFields.count, 0, "This test cannot continue because there are no ResultFields.")
        continueAfterFailure = true

        for resultField in testProject.resultFields {
            for config in resultField.configs {
                assertGetConfigToProjectsRelationship(config)
                assertGetConfigToProjectsRelationship(config, usingObjectToRelationshipMethod: true)
            }
        }
    }

    // MARK: Run

    func testGetRunToAssignedtoRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.runs.count, 0, "This test cannot continue because there are no Runs.")
        continueAfterFailure = true

        for run in testProject.runs {
            assertGetRunToAssignedtoRelationship(run)
            assertGetRunToAssignedtoRelationship(run, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetRunToConfigurationsRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.runs.count, 0, "This test cannot continue because there are no Runs.")
        continueAfterFailure = true

        for run in testProject.runs {
            assertGetRunToConfigurationsRelationship(run)
            assertGetRunToConfigurationsRelationship(run, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetRunToCreatedByRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.runs.count, 0, "This test cannot continue because there are no Runs.")
        continueAfterFailure = true

        for run in testProject.runs {
            assertGetRunToCreatedByRelationship(run)
            assertGetRunToCreatedByRelationship(run, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetRunToMilestoneRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.runs.count, 0, "This test cannot continue because there are no Runs.")
        continueAfterFailure = true

        for run in testProject.runs {
            assertGetRunToMilestoneRelationship(run)
            assertGetRunToMilestoneRelationship(run, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetRunToPlanRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.runs.count, 0, "This test cannot continue because there are no Runs.")
        continueAfterFailure = true

        for run in testProject.runs {
            assertGetRunToPlanRelationship(run)
            assertGetRunToPlanRelationship(run, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetRunToProjectRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.runs.count, 0, "This test cannot continue because there are no Runs.")
        continueAfterFailure = true

        for run in testProject.runs {
            assertGetRunToProjectRelationship(run)
            assertGetRunToProjectRelationship(run, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetRunToSuiteRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.runs.count, 0, "This test cannot continue because there are no Runs.")
        continueAfterFailure = true

        for run in testProject.runs {
            assertGetRunToSuiteRelationship(run)
            assertGetRunToSuiteRelationship(run, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: Section

    func testGetSectionToParentRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.sections.count, 0, "This test cannot continue because there are no Sections.")
        continueAfterFailure = true

        for section in testProject.sections {
            assertGetSectionToParentRelationship(section)
            assertGetSectionToParentRelationship(section, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetSectionToSuiteRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.sections.count, 0, "This test cannot continue because there are no Sections.")
        continueAfterFailure = true

        for section in testProject.sections {
            assertGetSectionToSuiteRelationship(section)
            assertGetSectionToSuiteRelationship(section, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: Suite

    func testGetSuiteToProjectRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.suites.count, 0, "This test cannot continue because there are no Suites.")
        continueAfterFailure = true

        for suite in testProject.suites {
            assertGetSuiteToProjectRelationship(suite)
            assertGetSuiteToProjectRelationship(suite, usingObjectToRelationshipMethod: true)
        }
    }

    // MARK: Test

    func testGetTestToAssignedtoRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.tests.count, 0, "This test cannot continue because there are no Tests.")
        continueAfterFailure = true

        for test in testProject.tests {
            assertGetTestToAssignedtoRelationship(test)
            assertGetTestToAssignedtoRelationship(test, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetTestToCaseRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.tests.count, 0, "This test cannot continue because there are no Tests.")
        continueAfterFailure = true

        for test in testProject.tests {
            assertGetTestToCaseRelationship(test)
            assertGetTestToCaseRelationship(test, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetTestToMilestoneRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.tests.count, 0, "This test cannot continue because there are no Tests.")
        continueAfterFailure = true

        for test in testProject.tests {
            assertGetTestToMilestoneRelationship(test)
            assertGetTestToMilestoneRelationship(test, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetTestToPriorityRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.tests.count, 0, "This test cannot continue because there are no Tests.")
        continueAfterFailure = true

        for test in testProject.tests {
            assertGetTestToPriorityRelationship(test)
            assertGetTestToPriorityRelationship(test, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetTestToRunRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.tests.count, 0, "This test cannot continue because there are no Tests.")
        continueAfterFailure = true

        for test in testProject.tests {
            assertGetTestToRunRelationship(test)
            assertGetTestToRunRelationship(test, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetTestToStatusRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.tests.count, 0, "This test cannot continue because there are no Tests.")
        continueAfterFailure = true

        for test in testProject.tests {
            assertGetTestToStatusRelationship(test)
            assertGetTestToStatusRelationship(test, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetTestToTemplateRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.tests.count, 0, "This test cannot continue because there are no Tests.")
        continueAfterFailure = true

        for test in testProject.tests {
            assertGetTestToTemplateRelationship(test)
            assertGetTestToTemplateRelationship(test, usingObjectToRelationshipMethod: true)
        }
    }

    func testGetTestToTypeRelationship() {

        continueAfterFailure = false
        XCTAssertGreaterThan(testProject.tests.count, 0, "This test cannot continue because there are no Tests.")
        continueAfterFailure = true

        for test in testProject.tests {
            assertGetTestToTypeRelationship(test)
            assertGetTestToTypeRelationship(test, usingObjectToRelationshipMethod: true)
        }
    }

}

// MARK: - Assertions: Helpers

extension ObjectAPITests {

    // MARK: Outcome

    func assertOutcomeSucceeded<ObjectType, ErrorType: CustomDebugStringConvertible>(_ outcome: Outcome<ObjectType, ErrorType>) -> ObjectType? {
        let object: ObjectType?
        switch outcome {
        case .failure(let error):
            XCTFail(error.debugDescription)
            object = nil
        case .success(let _object):
            object = _object
        }
        return object
    }

    func assertOutcomeSucceeded<ObjectType, ErrorType: CustomDebugStringConvertible>(_ outcome: Outcome<ObjectType?, ErrorType>) -> ObjectType? {
        let object: ObjectType?
        switch outcome {
        case .failure(let error):
            XCTFail(error.debugDescription)
            object = nil
        case .success(let _object):
            object = _object
        }
        return object
    }

    // MARK: CustomFields

    /*
     TestRail may add any omitted custom fields when creating a new object. Use
     this to methods to assert only provided custom fields during an add
     request.
     */
    func assertCustomFieldKeyValuePairs(in lhs: CustomFields, existIn rhs: CustomFields) {
        for (key, _) in lhs.customFields {
            XCTAssertNotNil(rhs.customFields[key])
        }
    }

}

// MARK: - Assertions: Objects

extension ObjectAPITests {

    // MARK: Case

    @discardableResult func assertAddCase(_ newCase: NewCase, to section: Section) -> Case? {

        let expectation = XCTestExpectation(description: "Add Case")

        var `case`: Case?
        objectAPI.addCase(newCase, to: section) { (outcome) in
            `case` = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(`case`)

        if let `case` = `case` {

            XCTAssertEqual(`case`.sectionId, section.id)
            XCTAssertEqual(`case`.title, newCase.title)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newCase.estimate { XCTAssertEqual(value, `case`.estimate) }
            if let value = newCase.milestoneId { XCTAssertEqual(value, `case`.milestoneId) }
            if let value = newCase.priorityId { XCTAssertEqual(value, `case`.priorityId) }
            if let value = newCase.refs { XCTAssertEqual(value, `case`.refs) }
            if let value = newCase.templateId { XCTAssertEqual(value, `case`.templateId) }
            if let value = newCase.typeId { XCTAssertEqual(value, `case`.typeId) }

            assertCustomFieldKeyValuePairs(in: newCase, existIn: `case`)
        }

        return `case`
    }

    func assertDeleteCase(_ case: Case) {

        let expectation = XCTestExpectation(description: "Delete Case")

        objectAPI.deleteCase(`case`) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertGetCase(_ caseId: Int) -> Case? {

        let expectation = XCTestExpectation(description: "Get Case")

        var `case`: Case?
        objectAPI.getCase(caseId) { (outcome) in
            `case` = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(`case`)

        if let `case` = `case` {
            XCTAssertEqual(`case`.id, caseId)
        }

        return `case`
    }

    @discardableResult func assertGetCases(in project: Project, in suite: Suite? = nil, in section: Section? = nil, filteredBy filters: [Filter]? = nil) -> [Case]? {

        let expectation = XCTestExpectation(description: "Get Cases")

        var cases: [Case]?
        objectAPI.getCases(in: project, in: suite, in: section, filteredBy: filters) { (outcome) in
            cases = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(cases)

        if let cases = cases {
            for `case` in cases {
                XCTAssertEqual(`case`.suiteId, suite?.id)
                XCTAssertEqual(`case`.sectionId, section?.id)
            }
        }

        return cases
    }

    @discardableResult func assertUpdateCase(_ case: Case) -> Case? {

        let expectation = XCTestExpectation(description: "Update Case")

        var updatedCase: Case?
        objectAPI.updateCase(`case`) { (outcome) in
            updatedCase = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedCase)

        if let updatedCase = updatedCase {
            // Identity
            XCTAssertEqual(updatedCase.id, `case`.id)
            // Updates
            XCTAssertEqual(updatedCase.estimate, `case`.estimate)
            XCTAssertEqual(updatedCase.milestoneId, `case`.milestoneId)
            XCTAssertEqual(updatedCase.priorityId, `case`.priorityId)
            XCTAssertEqual(updatedCase.refs, `case`.refs)
            XCTAssertEqual(updatedCase.templateId, `case`.templateId)
            XCTAssertEqual(updatedCase.title, `case`.title)
            XCTAssertEqual(updatedCase.typeId, `case`.typeId)
            XCTAssertEqual(updatedCase.customFieldsContainer, `case`.customFieldsContainer)
        }

        return updatedCase
    }

    // MARK: CaseField

    @discardableResult func assertGetCaseFields() -> [CaseField]? {

        let expectation = XCTestExpectation(description: "Get Case Fields")

        var caseFields: [CaseField]?
        objectAPI.getCaseFields { (outcome) in
            caseFields = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(caseFields)

        return caseFields
    }

    // swiftlint:disable:next cyclomatic_complexity
    @discardableResult func assertAddCaseField<DataType: NewCaseFieldData>(_ newCaseField: NewCaseField<DataType>) -> CaseField? {

        let expectation = XCTestExpectation(description: "Add Case Field")

        var caseField: CaseField?
        objectAPI.addCaseField(newCaseField) { (outcome) in
            caseField = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(caseField)

        if let caseField = caseField {

            // Common
            XCTAssertEqual(caseField.description, newCaseField.description)
            XCTAssertEqual(caseField.includeAll, newCaseField.includeAll)
            XCTAssertEqual(caseField.label, newCaseField.label)
            XCTAssertEqual(caseField.name, newCaseField.name)
            XCTAssertEqual(caseField.templateIds, newCaseField.templateIds)
            XCTAssertTrue(caseField.typeId == newCaseField.type)

            // Common Config.Context
            XCTAssertEqual(caseField.configs[0].context.isGlobal, newCaseField.configs[0].context.isGlobal)
            XCTAssertEqual((caseField.configs[0].context.projectIds ?? []), newCaseField.configs[0].context.projectIds)

            // Type Specific Config.Options
            if caseField.typeId == newCaseField.type {
                switch newCaseField.type {
                case .string:
                    let data = newCaseField.data as! NewCaseFieldStringData
                    let options = data.configs[0].options
                    let defaultValue = options.defaultValue ?? ""
                    XCTAssertEqual(defaultValue, caseField.configs[0].options["default_value"] as? String)
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                case .integer:
                    let data = newCaseField.data as! NewCaseFieldIntegerData
                    let options = data.configs[0].options
                    let defaultValue = options.defaultValue != nil ? String(options.defaultValue!) : ""
                    XCTAssertEqual(defaultValue, caseField.configs[0].options["default_value"] as? String)
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                case .text:
                    let data = newCaseField.data as! NewCaseFieldTextData
                    let options = data.configs[0].options
                    let defaultValue = options.defaultValue ?? ""
                    XCTAssertEqual(defaultValue, caseField.configs[0].options["default_value"] as? String)
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                    XCTAssertEqual(options.format.rawValue, caseField.configs[0].options["format"] as? String)
                    XCTAssertEqual(options.rows.rawValue, caseField.configs[0].options["rows"] as? String)
                case .url:
                    let data = newCaseField.data as! NewCaseFieldURLData
                    let options = data.configs[0].options
                    let defaultValue = options.defaultValue?.absoluteString ?? ""
                    XCTAssertEqual(defaultValue, caseField.configs[0].options["default_value"] as? String)
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                case .checkbox:
                    let data = newCaseField.data as! NewCaseFieldCheckboxData
                    let options = data.configs[0].options
                    XCTAssertEqual(options.defaultValue, caseField.configs[0].options["default_value"] as? Bool)
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                case .dropdown:
                    let data = newCaseField.data as! NewCaseFieldDropdownData
                    let options = data.configs[0].options
                    let defaultValue = String((options.defaultValue + 1)) // 0 indexed ---> 1 indexed
                    XCTAssertEqual(defaultValue, caseField.configs[0].options["default_value"] as? String)
                    if let itemsString = caseField.configs[0].options["items"] as? String,
                        let items = CaseFieldItemsConverter.items(from: itemsString) {
                        XCTAssertEqual(options.items, items)
                    } else {
                        XCTFail("Invalid items: \(String(describing: caseField.configs[0].options["items"]))")
                    }
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                case .user:
                    let data = newCaseField.data as! NewCaseFieldUserData
                    let options = data.configs[0].options
                    let defaultValue = options.defaultValue != nil ? String(options.defaultValue!) : ""
                    XCTAssertEqual(defaultValue, caseField.configs[0].options["default_value"] as? String)
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                case .date:
                    let data = newCaseField.data as! NewCaseFieldDateData
                    let options = data.configs[0].options
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                case .milestone:
                    let data = newCaseField.data as! NewCaseFieldMilestoneData
                    let options = data.configs[0].options
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                case .steps:
                    let data = newCaseField.data as! NewCaseFieldStepsData
                    let options = data.configs[0].options
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                    XCTAssertEqual(options.format.rawValue, caseField.configs[0].options["format"] as? String)
                    XCTAssertEqual(options.hasExpected, caseField.configs[0].options["has_expected"] as? Bool)
                    XCTAssertEqual(options.rows.rawValue, caseField.configs[0].options["rows"] as? String)
                case .multiselect:
                    let data = newCaseField.data as! NewCaseFieldMultiselectData
                    let options = data.configs[0].options
                    if let itemsString = caseField.configs[0].options["items"] as? String,
                        let items = CaseFieldItemsConverter.items(from: itemsString) {
                        XCTAssertEqual(options.items, items)
                    } else {
                        XCTFail("Invalid items: \(String(describing: caseField.configs[0].options["items"]))")
                    }
                    XCTAssertEqual(options.isRequired, caseField.configs[0].options["is_required"] as? Bool)
                }
            }
        }

        return caseField
    }

    // MARK: CaseType

    @discardableResult func assertGetCaseTypes() -> [CaseType]? {

        let expectation = XCTestExpectation(description: "Get Case Types")

        var caseTypes: [CaseType]?
        objectAPI.getCaseTypes { (outcome) in
            caseTypes = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(caseTypes)

        return caseTypes
    }

    // MARK: Configuration

    @discardableResult func assertAddConfiguration(_ newConfiguration: NewConfiguration, to configurationGroup: ConfigurationGroup) -> Configuration? {

        let expectation = XCTestExpectation(description: "Add Configuration")

        var configuration: Configuration?
        objectAPI.addConfiguration(newConfiguration, to: configurationGroup) { (outcome) in
            configuration = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(configuration)

        if let configuration = configuration {
            XCTAssertEqual(configuration.name, newConfiguration.name)
            XCTAssertEqual(configuration.groupId, configurationGroup.id)
        }

        return configuration
    }

    func assertDeleteConfiguration(_ configuration: Configuration) {

        let expectation = XCTestExpectation(description: "Delete Configuration")

        objectAPI.deleteConfiguration(configuration) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertUpdateConfiguration(_ configuration: Configuration) -> Configuration? {

        let expectation = XCTestExpectation(description: "Update Configuration")

        var updatedConfiguration: Configuration?
        objectAPI.updateConfiguration(configuration) { (outcome) in
            updatedConfiguration = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedConfiguration)

        if let updatedConfiguration = updatedConfiguration {
            // Identity
            XCTAssertEqual(updatedConfiguration.id, configuration.id)
            // Updates
            XCTAssertEqual(updatedConfiguration.name, configuration.name)
        }

        return updatedConfiguration
    }

    // MARK: ConfigurationGroup

    @discardableResult func assertAddConfigurationGroup(_ newConfigurationGroup: NewConfigurationGroup, to project: Project) -> ConfigurationGroup? {

        let expectation = XCTestExpectation(description: "Add Configuration Group")

        var configurationGroup: ConfigurationGroup?
        objectAPI.addConfigurationGroup(newConfigurationGroup, to: project) { (outcome) in
            configurationGroup = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(configurationGroup)

        if let configurationGroup = configurationGroup {
            XCTAssertEqual(configurationGroup.name, newConfigurationGroup.name)
            XCTAssertEqual(configurationGroup.projectId, project.id)
        }

        return configurationGroup
    }

    func assertDeleteConfigurationGroup(_ configurationGroup: ConfigurationGroup) {

        let expectation = XCTestExpectation(description: "Delete Configuration Group")

        objectAPI.deleteConfigurationGroup(configurationGroup) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertGetConfigurationGroups() -> [ConfigurationGroup]? {

        let expectation = XCTestExpectation(description: "Get Configuration Groups")

        var configurationGroups: [ConfigurationGroup]?
        objectAPI.getConfigurationGroups { (outcome) in
            configurationGroups = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(configurationGroups)

        return configurationGroups
    }

    @discardableResult func assertGetConfigurationGroups(in project: Project) -> [ConfigurationGroup]? {

        let expectation = XCTestExpectation(description: "Get Configuration Groups In Project")

        var configurationGroups: [ConfigurationGroup]?
        objectAPI.getConfigurationGroups(in: project) { (outcome) in
            configurationGroups = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(configurationGroups)

        if let configurationGroups = configurationGroups {
            for configurationGroup in configurationGroups {
                XCTAssertEqual(configurationGroup.projectId, project.id)
            }
        }

        return configurationGroups
    }

    @discardableResult func assertUpdateConfigurationGroup(_ configurationGroup: ConfigurationGroup) -> ConfigurationGroup? {

        let expectation = XCTestExpectation(description: "Update Configuration Group")

        var updatedConfigurationGroup: ConfigurationGroup?
        objectAPI.updateConfigurationGroup(configurationGroup) { (outcome) in
            updatedConfigurationGroup = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedConfigurationGroup)

        if let updatedConfigurationGroup = updatedConfigurationGroup {
            // Identity
            XCTAssertEqual(updatedConfigurationGroup.id, configurationGroup.id)
            // Updates
            XCTAssertEqual(updatedConfigurationGroup.name, configurationGroup.name)
        }

        return updatedConfigurationGroup
    }

    // MARK: Milestone

    @discardableResult func assertAddMilestone(_ newMilestone: NewMilestone, to project: Project) -> Milestone? {

        let expectation = XCTestExpectation(description: "Add Milestone")

        var milestone: Milestone?
        objectAPI.addMilestone(newMilestone, to: project) { (outcome) in
            milestone = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(milestone)

        if let milestone = milestone {

            XCTAssertEqual(milestone.name, newMilestone.name)
            XCTAssertEqual(milestone.projectId, project.id)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newMilestone.description { XCTAssertEqual(value, milestone.description) }
            if let value = newMilestone.dueOn?.secondsSince1970 { XCTAssertEqual(value, milestone.dueOn?.secondsSince1970) }
            if let value = newMilestone.parentId { XCTAssertEqual(value, milestone.parentId) }
            if let value = newMilestone.startOn?.secondsSince1970 { XCTAssertEqual(value, milestone.startOn?.secondsSince1970) }
        }

        return milestone
    }

    func assertDeleteMilestone(_ milestone: Milestone) {

        let expectation = XCTestExpectation(description: "Delete Milestone")

        objectAPI.deleteMilestone(milestone) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertGetMilestone(_ milestoneId: Int) -> Milestone? {

        let expectation = XCTestExpectation(description: "Get Milestone")

        var milestone: Milestone?
        objectAPI.getMilestone(milestoneId) { (outcome) in
            milestone = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(milestone)

        if let milestone = milestone {
            XCTAssertEqual(milestone.id, milestoneId)
        }

        return milestone
    }

    @discardableResult func assertGetMilestones(in project: Project, filteredBy filters: [Filter]? = nil) -> [Milestone]? {

        let expectation = XCTestExpectation(description: "Get Milestones")

        var milestones: [Milestone]?
        objectAPI.getMilestones(in: project, filteredBy: filters) { (outcome) in
            milestones = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(milestones)

        if let milestones = milestones {
            for milestone in milestones {
                XCTAssertEqual(milestone.projectId, project.id)
            }
        }

        return milestones
    }

    @discardableResult func assertUpdateMilestone(_ milestone: Milestone) -> Milestone? {

        let expectation = XCTestExpectation(description: "Update Milestone")

        var updatedMilestone: Milestone?
        objectAPI.updateMilestone(milestone) { (outcome) in
            updatedMilestone = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedMilestone)

        if let updatedMilestone = updatedMilestone {
            // Identity
            XCTAssertEqual(updatedMilestone.id, milestone.id)
            // Updates
            XCTAssertEqual(updatedMilestone.description, milestone.description)
            XCTAssertEqual(updatedMilestone.dueOn?.secondsSince1970, milestone.dueOn?.secondsSince1970)
            XCTAssertEqual(updatedMilestone.isCompleted, milestone.isCompleted)
            XCTAssertEqual(updatedMilestone.isStarted, milestone.isStarted)
            XCTAssertEqual(updatedMilestone.name, milestone.name)
            XCTAssertEqual(updatedMilestone.parentId, milestone.parentId)
            XCTAssertEqual(updatedMilestone.startOn?.secondsSince1970, milestone.startOn?.secondsSince1970)
        }

        return updatedMilestone
    }

    // MARK: Plan

    @discardableResult func assertAddPlan(_ newPlan: NewPlan, to project: Project) -> Plan? {

        let expectation = XCTestExpectation(description: "Add Plan")

        var plan: Plan?
        objectAPI.addPlan(newPlan, to: project) { (outcome) in
            plan = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(plan)

        if let plan = plan {

            XCTAssertEqual(plan.name, newPlan.name)
            XCTAssertEqual(plan.projectId, project.id)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newPlan.description { XCTAssertEqual(value, plan.description) }
            if let value = newPlan.milestoneId { XCTAssertEqual(value, plan.milestoneId) }
            if let value = newPlan.entries { XCTAssertEqual(value.count, plan.entries?.count) }
        }

        return plan
    }

    @discardableResult func assertClosePlan(_ plan: Plan) -> Plan? {

        let expectation = XCTestExpectation(description: "Close Plan")

        var closedPlan: Plan?
        objectAPI.closePlan(plan) { (outcome) in
            closedPlan = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(closedPlan)

        if let closedPlan = closedPlan {
            XCTAssertNotNil(closedPlan.completedOn)
            XCTAssertEqual(closedPlan.isCompleted, true)
        }

        return closedPlan
    }

    func assertDeletePlan(_ plan: Plan) {

        let expectation = XCTestExpectation(description: "Delete Plan")

        objectAPI.deletePlan(plan) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertGetPlan(_ planId: Int) -> Plan? {

        let expectation = XCTestExpectation(description: "Get Plan")

        var plan: Plan?
        objectAPI.getPlan(planId) { (outcome) in
            plan = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(plan)

        if let plan = plan {
            XCTAssertEqual(plan.id, planId)
        }

        return plan
    }

    @discardableResult func assertGetPlans(in project: Project, filteredBy filters: [Filter]? = nil) -> [Plan]? {

        let expectation = XCTestExpectation(description: "Get Plans")

        var plans: [Plan]?
        objectAPI.getPlans(in: project, filteredBy: filters) { (outcome) in
            plans = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(plans)

        if let plans = plans {
            for plan in plans {
                XCTAssertEqual(plan.projectId, project.id)
            }
        }

        return plans
    }

    @discardableResult func assertUpdatePlan(_ plan: Plan) -> Plan? {

        let expectation = XCTestExpectation(description: "Update Plan")

        var updatedPlan: Plan?
        objectAPI.updatePlan(plan) { (outcome) in
            updatedPlan = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedPlan)

        if let updatedPlan = updatedPlan {
            // Identity
            XCTAssertEqual(updatedPlan.id, plan.id)
            // Updates
            XCTAssertEqual(updatedPlan.description, plan.description)
            XCTAssertEqual(updatedPlan.milestoneId, plan.milestoneId)
            XCTAssertEqual(updatedPlan.name, plan.name)
        }

        return updatedPlan
    }

    // MARK: Plan.Entry

    @discardableResult func assertAddPlanEntry(_ newPlanEntry: NewPlan.Entry, to plan: Plan) -> Plan.Entry? {

        let expectation = XCTestExpectation(description: "Add Plan Entry")

        var planEntry: Plan.Entry?
        objectAPI.addPlanEntry(newPlanEntry, to: plan) { (outcome) in
            planEntry = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(planEntry)

        if let planEntry = planEntry {

            XCTAssertEqual(planEntry.suiteId, newPlanEntry.suiteId)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newPlanEntry.name { XCTAssertEqual(value, planEntry.name) }

            if let newPlanEntryRuns = newPlanEntry.runs, newPlanEntryRuns.count > 0 {
                XCTAssertEqual(planEntry.runs.count, newPlanEntryRuns.count)
            } else {
                // A default Run will be returned if newPlanEntry.runs was nil
                // or empty. This Run will include all tests for the Suite
                // matching the Suite for newPlanEntry.suiteId.
                XCTAssertEqual(planEntry.runs.count, 1)
            }
        }

        return planEntry
    }

    func assertDeletePlanEntry(_ planEntry: Plan.Entry, from plan: Plan) {

        let expectation = XCTestExpectation(description: "Delete Plan Entry")

        objectAPI.deletePlanEntry(planEntry, from: plan) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertUpdatePlanEntry(_ planEntry: Plan.Entry, in plan: Plan, with planEntryRuns: UpdatePlanEntryRuns? = nil) -> Plan.Entry? {

        let expectation = XCTestExpectation(description: "Update Plan Entry")

        var updatedPlanEntry: Plan.Entry?
        objectAPI.updatePlanEntry(planEntry, in: plan, with: planEntryRuns) { (outcome) in
            updatedPlanEntry = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedPlanEntry)

        if let updatedPlanEntry = updatedPlanEntry {

            // Identity
            XCTAssertEqual(updatedPlanEntry.id, planEntry.id)

            // Updates
            XCTAssertEqual(updatedPlanEntry.name, planEntry.name)
        }

        return updatedPlanEntry
    }

    // MARK: Priority

    @discardableResult func assertGetPriorities() -> [Priority]? {

        let expectation = XCTestExpectation(description: "Get Priorities")

        var priorities: [Priority]?
        objectAPI.getPriorities { (outcome) in
            priorities = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(priorities)

        return priorities
    }

    // MARK: Project

    @discardableResult func assertAddProject(_ newProject: NewProject) -> Project? {

        let expectation = XCTestExpectation(description: "Add Project")

        var project: Project?
        objectAPI.addProject(newProject) { (outcome) in
            project = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(project)

        if let project = project {

            XCTAssertEqual(project.name, newProject.name)
            XCTAssertEqual(project.showAnnouncement, newProject.showAnnouncement)
            XCTAssertEqual(newProject.suiteMode, newProject.suiteMode)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newProject.announcement { XCTAssertEqual(value, project.announcement) }
        }

        return project
    }

    func assertDeleteProject(_ project: Project) {

        let expectation = XCTestExpectation(description: "Test Delete Project")

        objectAPI.deleteProject(project) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertGetProject(_ projectId: Int) -> Project? {

        let expectation = XCTestExpectation(description: "Get Project")

        var project: Project?
        objectAPI.getProject(projectId) { (outcome) in
            project = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(project)

        if let project = project {
            XCTAssertEqual(project.id, projectId)
        }

        return project
    }

    @discardableResult func assertGetProjects() -> [Project]? {

        let expectation = XCTestExpectation(description: "Get Projects")

        var projects: [Project]?
        objectAPI.getProjects { (outcome) in
            projects = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(projects)

        return projects
    }

    @discardableResult func assertUpdateProject(_ project: Project) -> Project? {

        let expectation = XCTestExpectation(description: "Update Projects")

        var updatedProject: Project?
        objectAPI.updateProject(project) { (outcome) in
            updatedProject = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedProject)

        if let updatedProject = updatedProject {
            // Identity
            XCTAssertEqual(updatedProject.id, project.id)
            // Updates
            XCTAssertEqual(updatedProject.announcement, project.announcement)
            XCTAssertEqual(updatedProject.isCompleted, project.isCompleted)
            XCTAssertEqual(updatedProject.name, project.name)
            XCTAssertEqual(updatedProject.showAnnouncement, project.showAnnouncement)
            XCTAssertEqual(updatedProject.suiteMode, project.suiteMode)
        }

        return updatedProject
    }

    // MARK: Result

    @discardableResult func assertAddResult(_ newResult: NewResult, to test: Test) -> Result? {

        let expectation = XCTestExpectation(description: "Add Result")

        var result: Result?
        objectAPI.addResult(newResult, to: test) { (outcome) in
            result = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(result)

        if let result = result {

            XCTAssertEqual(result.statusId, newResult.statusId)
            XCTAssertEqual(result.testId, test.id)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newResult.assignedtoId { XCTAssertEqual(value, result.assignedtoId) }
            if let value = newResult.comment { XCTAssertEqual(value, result.comment) }
            if let value = newResult.defects { XCTAssertEqual(value, result.defects) }
            if let value = newResult.elapsed { XCTAssertEqual(value, result.elapsed) }
            if let value = newResult.version { XCTAssertEqual(value, result.version) }

            assertCustomFieldKeyValuePairs(in: newResult, existIn: result)
        }

        return result
    }

    @discardableResult func assertAddResultForCase(_ newResult: NewResult, to run: Run, to case: Case) -> Result? {

        let expectation = XCTestExpectation(description: "Add Result For Case")

        var result: Result?
        objectAPI.addResultForCase(newResult, to: run, to: `case`) { (outcome) in
            result = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(result)

        if let result = result {

            XCTAssertEqual(result.statusId, newResult.statusId)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newResult.assignedtoId { XCTAssertEqual(value, result.assignedtoId) }
            if let value = newResult.comment { XCTAssertEqual(value, result.comment) }
            if let value = newResult.defects { XCTAssertEqual(value, result.defects) }
            if let value = newResult.elapsed { XCTAssertEqual(value, result.elapsed) }
            if let value = newResult.version { XCTAssertEqual(value, result.version) }

            assertCustomFieldKeyValuePairs(in: newResult, existIn: result)
        }

        return result
    }

    @discardableResult func assertAddResults(_ newTestResults: NewTestResults, to run: Run) -> [Result]? {

        let expectation = XCTestExpectation(description: "Add Results")

        var results: [Result]?
        objectAPI.addResults(newTestResults, to: run) { (outcome) in
            results = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(results)

        if let results = results {
            XCTAssertEqual(results.count, newTestResults.results.count)
        }

        return results
    }

    @discardableResult func assertAddResultsForCases(_ newCaseResults: NewCaseResults, to run: Run) -> [Result]? {

        let expectation = XCTestExpectation(description: "Add Results For Cases")

        var results: [Result]?
        objectAPI.addResultsForCases(newCaseResults, to: run) { (outcome) in
            results = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(results)

        if let results = results {
            XCTAssertEqual(results.count, newCaseResults.results.count)
        }

        return results
    }

    @discardableResult func assertGetResultsForTest(_ test: Test, filteredBy filters: [Filter]? = nil) -> [Result]? {

        let expectation = XCTestExpectation(description: "Get Results For Test")

        var results: [Result]?
        objectAPI.getResultsForTest(test, filteredBy: filters) { (outcome) in
            results = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(results)

        return results
    }

    @discardableResult func assertGetResultsForCase(_ case: Case, in run: Run, filteredBy filters: [Filter]? = nil) -> [Result]? {

        let expectation = XCTestExpectation(description: "Get Results For Case")

        var results: [Result]?
        objectAPI.getResultsForCase(`case`, in: run, filteredBy: filters) { (outcome) in
            results = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(results)

        return results
    }

    @discardableResult func assertGetResultsForRun(_ run: Run, filteredBy filters: [Filter]? = nil) -> [Result]? {

        let expectation = XCTestExpectation(description: "Get Results For Run")

        var results: [Result]?
        objectAPI.getResultsForRun(run, filteredBy: filters) { (outcome) in
            results = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(results)

        return results
    }

    // MARK: ResultField

    @discardableResult func assertGetResultFields() -> [ResultField]? {

        let expectation = XCTestExpectation(description: "Get ResultFields")

        var resultFields: [ResultField]?
        objectAPI.getResultFields { (outcome) in
            resultFields = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(resultFields)

        return resultFields
    }

    // MARK: Run

    @discardableResult func assertAddRun(_ newRun: NewRun, to project: Project) -> Run? {

        let expectation = XCTestExpectation(description: "Add Run")

        var run: Run?
        objectAPI.addRun(newRun, to: project) { (outcome) in
            run = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(run)

        if let run = run {

            XCTAssertEqual(run.includeAll, newRun.includeAll)
            XCTAssertEqual(run.name, newRun.name)
            XCTAssertEqual(run.projectId, project.id)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newRun.assignedtoId { XCTAssertEqual(value, run.assignedtoId) }
            if let value = newRun.description { XCTAssertEqual(value, run.description) }
            if let value = newRun.milestoneId { XCTAssertEqual(value, run.milestoneId) }
            if let value = newRun.suiteId { XCTAssertEqual(value, run.suiteId) }
        }

        return run
    }

    @discardableResult func assertCloseRun(_ run: Run) -> Run? {

        let expectation = XCTestExpectation(description: "Close Run")

        var closedRun: Run?
        objectAPI.closeRun(run) { (outcome) in
            closedRun = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(closedRun)

        if let closedRun = closedRun {
            XCTAssertNotNil(closedRun.completedOn)
            XCTAssertTrue(closedRun.isCompleted)
            XCTAssertEqual(closedRun.id, run.id)
        }

        return closedRun
    }

    func assertDeleteRun(_ run: Run) {

        let expectation = XCTestExpectation(description: "Delete Run")

        objectAPI.deleteRun(run) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertGetRun(_ runId: Int) -> Run? {

        let expectation = XCTestExpectation(description: "Get Run")

        var run: Run?
        objectAPI.getRun(runId) { (outcome) in
            run = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(run)

        if let run = run {
            XCTAssertEqual(run.id, runId)
        }

        return run
    }

    @discardableResult func assertGetRuns(in project: Project, filteredBy filters: [Filter]? = nil) -> [Run]? {

        let expectation = XCTestExpectation(description: "Get Runs")

        var runs: [Run]?
        objectAPI.getRuns(in: project, filteredBy: filters) { (outcome) in
            runs = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(runs)

        if let runs = runs {
            for run in runs {
                XCTAssertEqual(run.projectId, project.id)
            }
        }

        return runs
    }

    @discardableResult func assertUpdateRun(_ run: Run) -> Run? {

        let expectation = XCTestExpectation(description: "Update Run")

        var updatedRun: Run?
        objectAPI.updateRun(run) { (outcome) in
            updatedRun = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedRun)

        if let updatedRun = updatedRun {
            // Identity
            XCTAssertEqual(updatedRun.id, run.id)
            // Updates
            XCTAssertEqual(updatedRun.description, run.description)
            XCTAssertEqual(updatedRun.includeAll, run.includeAll)
            XCTAssertEqual(updatedRun.milestoneId, run.milestoneId)
            XCTAssertEqual(updatedRun.name, run.name)
        }

        return updatedRun
    }

    // MARK: Section

    @discardableResult func assertAddSection(_ newSection: NewSection, to project: Project) -> Section? {

        let expectation = XCTestExpectation(description: "Add Section")

        var section: Section?
        objectAPI.addSection(newSection, to: project) { (outcome) in
            section = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(section)

        if let section = section {

            XCTAssertEqual(section.name, newSection.name)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newSection.description { XCTAssertEqual(value, section.description) }
            if let value = newSection.parentId { XCTAssertEqual(value, section.parentId) }

            if project.suiteMode == .singleSuite {
                XCTAssertNil(section.suiteId) // Optional/ignored if project is running in single suite mode, otherwise required.
            } else {
                XCTAssertNotNil(section.suiteId)
                if let value = newSection.suiteId { XCTAssertEqual(value, section.suiteId) }
            }
        }

        return section
    }

    func assertDeleteSection(_ section: Section) {

        let expectation = XCTestExpectation(description: "Delete Section")

        objectAPI.deleteSection(section) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertGetSection(_ sectionId: Int) -> Section? {

        let expectation = XCTestExpectation(description: "Get Section")

        var section: Section?
        objectAPI.getSection(sectionId) { (outcome) in
            section = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(section)

        if let section = section {
            XCTAssertEqual(section.id, sectionId)
        }

        return section
    }

    @discardableResult func assertGetSections(in project: Project, in suite: Suite? = nil) -> [Section]? {

        let expectation = XCTestExpectation(description: "Get Sections")

        var sections: [Section]?
        objectAPI.getSections(in: project, in: suite) { (outcome) in
            sections = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(sections)

        if let sections = sections, let suite = suite {
            for section in sections {
                XCTAssertEqual(section.suiteId, suite.id)
            }
        }

        return sections
    }

    @discardableResult func assertUpdateSection(_ section: Section) -> Section? {

        let expectation = XCTestExpectation(description: "Update Section")

        var updatedSection: Section?
        objectAPI.updateSection(section) { (outcome) in
            updatedSection = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedSection)

        if let updatedSection = updatedSection {
            // Identity
            XCTAssertEqual(updatedSection.id, section.id)
            // Updates
            XCTAssertEqual(updatedSection.description, section.description)
            XCTAssertEqual(updatedSection.name, section.name)
        }

        return updatedSection
    }

    // MARK: Status

    @discardableResult func assertGetStatuses() -> [Status]? {

        let expectation = XCTestExpectation(description: "Get Statuses")

        var statuses: [Status]?
        objectAPI.getStatuses { (outcome) in
            statuses = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(statuses)

        return statuses
    }

    // MARK: Suite

    @discardableResult func assertAddSuite(_ newSuite: NewSuite, to project: Project) -> Suite? {

        let expectation = XCTestExpectation(description: "Add Suite")

        var suite: Suite?
        objectAPI.addSuite(newSuite, to: project) { (outcome) in
            suite = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(suite)

        if let suite = suite {

            XCTAssertEqual(suite.name, newSuite.name)
            XCTAssertEqual(suite.projectId, project.id)

            // TestRail may assign default values so only assert if nil was not passed in data.
            if let value = newSuite.description { XCTAssertEqual(value, suite.description) }
        }

        return suite
    }

    func assertDeleteSuite(_ suite: Suite) {

        let expectation = XCTestExpectation(description: "Delete Suite")

        objectAPI.deleteSuite(suite) { (outcome) in
            self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)
    }

    @discardableResult func assertGetSuite(_ suiteId: Int) -> Suite? {

        let expectation = XCTestExpectation(description: "Get Suite")

        var suite: Suite?
        objectAPI.getSuite(suiteId) { (outcome) in
            suite = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(suite)

        if let suite = suite {
            XCTAssertEqual(suite.id, suiteId)
        }

        return suite
    }

    @discardableResult func assertGetSuites(in project: Project) -> [Suite]? {

        let expectation = XCTestExpectation(description: "Get Suites")

        var suites: [Suite]?
        objectAPI.getSuites(in: project) { (outcome) in
            suites = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(suites)

        if let suites = suites {
            for suite in suites {
                XCTAssertEqual(suite.projectId, project.id)
            }
        }

        return suites
    }

    @discardableResult func assertUpdateSuite(_ suite: Suite) -> Suite? {

        let expectation = XCTestExpectation(description: "Update Suite")

        var updatedSuite: Suite?
        objectAPI.updateSuite(suite) { (outcome) in
            updatedSuite = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedSuite)

        if let updatedSuite = updatedSuite {
            // Identity
            XCTAssertEqual(updatedSuite.id, suite.id)
            // Updates
            XCTAssertEqual(updatedSuite.description, suite.description)
            XCTAssertEqual(updatedSuite.name, suite.name)
        }

        return updatedSuite
    }

    // MARK: Template

    @discardableResult func assertGetTemplates() -> [Template]? {

        let expectation = XCTestExpectation(description: "Get Templates")

        var templates: [Template]?
        objectAPI.getTemplates { (outcome) in
            templates = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(templates)

        return templates
    }

    @discardableResult func assertGetTemplates(in project: Project) -> [Template]? {

        let expectation = XCTestExpectation(description: "Get Templates In Project")

        var templates: [Template]?
        objectAPI.getTemplates(in: project) { (outcome) in
            templates = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(templates)

        return templates
    }

    // MARK: Test

    @discardableResult func assertGetTest(_ testId: Int) -> Test? {

        let expectation = XCTestExpectation(description: "Get Test")

        var test: Test?
        objectAPI.getTest(testId) { (outcome) in
            test = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(test)

        if let test = test {
            XCTAssertEqual(test.id, testId)
        }

        return test
    }

    @discardableResult func assertGetTests(in run: Run, filteredBy filters: [Filter]? = nil) -> [Test]? {

        let expectation = XCTestExpectation(description: "Get Tests")

        var tests: [Test]?
        objectAPI.getTests(in: run, filteredBy: filters) { (outcome) in
            tests = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(tests)

        if let tests = tests {
            for test in tests {
                XCTAssertEqual(test.runId, run.id)
            }
        }

        return tests
    }

    // MARK: User

    @discardableResult func assertGetUser(_ userId: Int) -> User? {

        let expectation = XCTestExpectation(description: "Get User")

        var user: User?
        objectAPI.getUser(userId) { (outcome) in
            user = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(user)

        if let user = user {
            XCTAssertEqual(user.id, userId)
        }

        return user
    }

    @discardableResult func assertGetUserByEmail(_ email: String) -> User? {

        let expectation = XCTestExpectation(description: "Get User by Email")

        var user: User?
        objectAPI.getUserByEmail(email) { (outcome) in
            user = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(user)

        if let user = user {
            XCTAssertEqual(user.email, email)
        }

        return user
    }

    @discardableResult func assertGetUsers(projectId: Int) -> [User]? {

        let expectation = XCTestExpectation(description: "Get Users")

        var users: [User]?
        objectAPI.getUsers(projectId) { (outcome) in
            users = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(users)

        if let users = users {
            XCTAssertNotEqual(users.count, 0)
        }

        return users
    }

}

// MARK: - Assertions: Object Matching

extension ObjectAPITests {

    // MARK: Case

    @discardableResult func assertGetCaseTypeMatchingId(_ id: Int) -> CaseType? {

        let expectation = XCTestExpectation(description: "Get CaseType Matching ID")

        var caseType: CaseType?
        objectAPI.getCaseType(matching: id) { (outcome) in
            caseType = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(caseType)

        if let caseType = caseType {
            XCTAssertEqual(caseType.id, id)
        }

        return caseType
    }

    // MARK: ConfigurationGroup

    @discardableResult func assertGetConfigurationGroupMatchingId(_ id: Int) -> ConfigurationGroup? {

        let expectation = XCTestExpectation(description: "Get ConfigurationGroup Matching ID")

        var configurationGroup: ConfigurationGroup?
        objectAPI.getConfigurationGroup(matching: id) { (outcome) in
            configurationGroup = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(configurationGroup)

        if let configurationGroup = configurationGroup {
            XCTAssertEqual(configurationGroup.id, id)
        }

        return configurationGroup
    }

    // MARK: Priority

    @discardableResult func assertGetPriorityMatchingId(_ id: Int) -> Priority? {

        let expectation = XCTestExpectation(description: "Get Priority Matching ID")

        var priority: Priority?
        objectAPI.getPriority(matching: id) { (outcome) in
            priority = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(priority)

        if let priority = priority {
            XCTAssertEqual(priority.id, id)
        }

        return priority
    }

    // MARK: Status

    @discardableResult func assertGetStatusMatchingId(_ id: Int) -> Status? {

        let expectation = XCTestExpectation(description: "Get Status Matching ID")

        var status: Status?
        objectAPI.getStatus(matching: id) { (outcome) in
            status = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(status)

        if let status = status {
            XCTAssertEqual(status.id, id)
        }

        return status
    }

    // MARK: Template

    @discardableResult func assertGetTemplateMatchingId(_ id: Int) -> Template? {

        let expectation = XCTestExpectation(description: "Get Template Matching ID")

        var template: Template?
        objectAPI.getTemplate(matching: id) { (outcome) in
            template = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(template)

        if let template = template {
            XCTAssertEqual(template.id, id)
        }

        return template
    }

    @discardableResult func assertGetTemplatesMatchingIds(_ ids: [Int]) -> [Template]? {

        let expectation = XCTestExpectation(description: "Get Templates Matching IDs")

        var templates: [Template]?
        objectAPI.getTemplates(matching: ids) { (outcome) in
            templates = self.assertOutcomeSucceeded(outcome)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(templates)

        if let templates = templates {
            let uniqueIds = Set(ids)
            XCTAssertEqual(uniqueIds.count, templates.count)
            for id in uniqueIds {
                XCTAssertEqual(templates.filter({ $0.id == id }).count, 1)
            }
        }

        return templates
    }

}

// MARK: - Assertions: Object Forward Relationships

extension ObjectAPITests {

    // MARK: Case

    @discardableResult func assertGetCaseToCreatedByRelationship(_ `case`: Case, usingObjectToRelationshipMethod: Bool = false) -> User? {

        let expectation = XCTestExpectation(description: "Get Case to CreatedBy (User) Relationship")

        var createdBy: User?
        if usingObjectToRelationshipMethod {
            `case`.createdBy(objectAPI) { (outcome) in
                createdBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.createdBy(`case`) { (outcome) in
                createdBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(createdBy)

        if let createdBy = createdBy {
            XCTAssertEqual(createdBy.id, `case`.createdBy)
        }

        return createdBy
    }

    @discardableResult func assertGetCaseToMilestoneRelationship(_ `case`: Case, usingObjectToRelationshipMethod: Bool = false) -> Milestone? {

        let expectation = XCTestExpectation(description: "Get Case to Milestone Relationship")

        var milestone: Milestone?
        if usingObjectToRelationshipMethod {
            `case`.milestone(objectAPI) { (outcome) in
                milestone = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.milestone(`case`) { (outcome) in
                milestone = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }

        }

        wait(for: [expectation], timeout: timeout)

        if let milestoneId = `case`.milestoneId {
            XCTAssertNotNil(milestone)
            if let milestone = milestone {
                XCTAssertEqual(milestone.id, milestoneId)
            }
        } else {
            XCTAssertNil(milestone)
        }

        return milestone
    }

    @discardableResult func assertGetCaseToPriorityRelationship(_ `case`: Case, usingObjectToRelationshipMethod: Bool = false) -> Priority? {

        let expectation = XCTestExpectation(description: "Get Case to Priority Relationship")

        var priority: Priority?
        if usingObjectToRelationshipMethod {
            `case`.priority(objectAPI) { (outcome) in
                priority = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.priority(`case`) { (outcome) in
                priority = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(priority)

        if let priority = priority {
            XCTAssertEqual(priority.id, `case`.priorityId)
        }

        return priority
    }

    @discardableResult func assertGetCaseToSectionRelationship(_ `case`: Case, usingObjectToRelationshipMethod: Bool = false) -> Section? {

        let expectation = XCTestExpectation(description: "Get Case to Section Relationship")

        var section: Section?
        if usingObjectToRelationshipMethod {
            `case`.section(objectAPI) { (outcome) in
                section = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.section(`case`) { (outcome) in
                section = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let sectionId = `case`.sectionId {
            XCTAssertNotNil(section)
            if let section = section {
                XCTAssertEqual(section.id, sectionId)
            }
        } else {
            XCTAssertNil(section)
        }

        return section
    }

    @discardableResult func assertGetCaseToSuiteRelationship(_ `case`: Case, usingObjectToRelationshipMethod: Bool = false) -> Suite? {

        let expectation = XCTestExpectation(description: "Get Case to Suite Relationship")

        var suite: Suite?
        if usingObjectToRelationshipMethod {
            `case`.suite(objectAPI) { (outcome) in
                suite = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.suite(`case`) { (outcome) in
                suite = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let suiteId = `case`.suiteId {
            XCTAssertNotNil(suite)
            if let suite = suite {
                XCTAssertEqual(suite.id, suiteId)
            }
        } else {
            XCTAssertNil(suite)
        }

        return suite
    }

    @discardableResult func assertGetCaseToTemplateRelationship(_ `case`: Case, usingObjectToRelationshipMethod: Bool = false) -> Template? {

        let expectation = XCTestExpectation(description: "Get Case to Template Relationship")

        var template: Template?
        if usingObjectToRelationshipMethod {
            `case`.template(objectAPI) { (outcome) in
                template = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.template(`case`) { (outcome) in
                template = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(template)

        if let template = template {
            XCTAssertEqual(template.id, `case`.templateId)
        }

        return template
    }

    @discardableResult func assertGetCaseToTypeRelationship(_ `case`: Case, usingObjectToRelationshipMethod: Bool = false) -> CaseType? {

        let expectation = XCTestExpectation(description: "Get Case to Type (CaseType) Relationship")

        var type: CaseType?
        if usingObjectToRelationshipMethod {
            `case`.type(objectAPI) { (outcome) in
                type = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.type(`case`) { (outcome) in
                type = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(type)

        if let type = type {
            XCTAssertEqual(type.id, `case`.typeId)
        }

        return type
    }

    @discardableResult func assertGetCaseToUpdatedByRelationship(_ `case`: Case, usingObjectToRelationshipMethod: Bool = false) -> User? {

        let expectation = XCTestExpectation(description: "Get Case to UpdatedBy (User) Relationship")

        var updatedBy: User?
        if usingObjectToRelationshipMethod {
            `case`.updatedBy(objectAPI) { (outcome) in
                updatedBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.updatedBy(`case`) { (outcome) in
                updatedBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(updatedBy)

        if let updatedBy = updatedBy {
            XCTAssertEqual(updatedBy.id, `case`.updatedBy)
        }

        return updatedBy
    }

    // MARK: Config

    @discardableResult func assertGetConfigToAccessibleProjectsRelationship(_ config: Config, usingObjectToRelationshipMethod: Bool = false) -> [Project]? {

        let expectation = XCTestExpectation(description: "Get Config to Accessible Projects Relationship")

        var projects: [Project]?
        if usingObjectToRelationshipMethod {
            config.accessibleProjects(objectAPI) { (outcome) in
                projects = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.accessibleProjects(config) { (outcome) in
                projects = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(projects)

        return projects
    }

    /*
     failOnMatchError true will cause a failure if any project returns a 403
     not authorized error. failOnMatchError false will not fail if 403's are
     returned as long as there are no other non-403 errors.

     403 errors might be unavoidable for some projects. For details see comments
     in the ObjectAPI.projects(...) method called here.
     */
    @discardableResult func assertGetConfigToProjectsRelationship(_ config: Config, usingObjectToRelationshipMethod: Bool = false, failOnMatchError: Bool = false) -> [Project]? {

        let expectation = XCTestExpectation(description: "Get Config to Projects Relationship")

        var _outcome: Outcome<[Project]?, ObjectAPI.MatchError<MultipleMatchError<Project, Project.Id>, ErrorContainer<ObjectAPI.GetError>>>?
        if usingObjectToRelationshipMethod {
            config.projects(objectAPI) { (outcome) in
                _outcome = outcome
                expectation.fulfill()
            }
        } else {
            objectAPI.projects(config) { (outcome) in
                _outcome = outcome
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        // Sanity: should never fail.
        guard let outcome = _outcome else {
            XCTAssertNotNil(_outcome)
            return nil
        }

        // Unpack outcome.
        var projects: [Project]?
        switch outcome {
        case .failure(let error):
            switch error {
            case .matchError(let matchError):
                if failOnMatchError {
                    XCTFail(error.debugDescription)
                } else {
                    print("\(#file):\(#line):\(#function) - WARNING: failOnMatchError is disabled. Partial matches will be returned: \(error.debugDescription)")
                    switch matchError {
                    case .noMatchesFound(_):
                        projects = []
                    case .partialMatchesFound(let matches, _):
                        projects = matches
                    }
                }
            default:
                XCTFail(error.debugDescription)
            }
        case .success(let _projects):
            projects = _projects
        }

        XCTAssertNotNil(projects)

        return projects
    }

    // MARK: CaseField

    @discardableResult func assertGetCaseFieldToTemplatesRelationship(_ caseField: CaseField, usingObjectToRelationshipMethod: Bool = false) -> [Template]? {

        let expectation = XCTestExpectation(description: "Get CaseField to Templates Relationship")

        var templates: [Template]?
        if usingObjectToRelationshipMethod {
            caseField.templates(objectAPI) { (outcome) in
                templates = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.templates(caseField) { (outcome) in
                templates = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(templates)

        if let templates = templates {
            XCTAssertEqual(templates.count, caseField.templateIds.count)
            for id in caseField.templateIds {
                XCTAssertEqual(templates.filter({ $0.id == id }).count, 1)
            }
        }

        return templates
    }

    // MARK: Configuration

    @discardableResult func assertGetConfigurationToConfigurationGroupRelationship(_ configuration: Configuration, usingObjectToRelationshipMethod: Bool = false) -> ConfigurationGroup? {

        let expectation = XCTestExpectation(description: "Get Configuration to ConfigurationGroup Relationship")

        var configurationGroup: ConfigurationGroup?
        if usingObjectToRelationshipMethod {
            configuration.configurationGroup(objectAPI) { (outcome) in
                configurationGroup = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.configurationGroup(configuration) { (outcome) in
                configurationGroup = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(configurationGroup)

        if let configurationGroup = configurationGroup {
            XCTAssertEqual(configurationGroup.id, configuration.groupId)
        }

        return configurationGroup
    }

    // MARK: ConfigurationGroup

    @discardableResult func assertGetConfigurationGroupToProjectRelationship(_ configurationGroup: ConfigurationGroup, usingObjectToRelationshipMethod: Bool = false) -> Project? {

        let expectation = XCTestExpectation(description: "Get ConfigurationGroup to Project Relationship")

        var project: Project?
        if usingObjectToRelationshipMethod {
            configurationGroup.project(objectAPI) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.project(configurationGroup) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(project)

        if let project = project {
            XCTAssertEqual(project.id, configurationGroup.projectId)
        }

        return project
    }

    // MARK: Milestone

    @discardableResult func assertGetMilestoneToParentRelationship(_ milestone: Milestone, usingObjectToRelationshipMethod: Bool = false) -> Milestone? {

        let expectation = XCTestExpectation(description: "Get Milestone to Parent (Milestone) Relationship")

        var parent: Milestone?
        if usingObjectToRelationshipMethod {
            milestone.parent(objectAPI) { (outcome) in
                parent = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.parent(milestone) { (outcome) in
                parent = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let parentId = milestone.parentId {
            XCTAssertNotNil(parent)
            if let parent = parent {
                XCTAssertEqual(parent.id, parentId)
            }
        } else {
            XCTAssertNil(parent)
        }

        return parent
    }

    @discardableResult func assertGetMilestoneToProjectRelationship(_ milestone: Milestone, usingObjectToRelationshipMethod: Bool = false) -> Project? {

        let expectation = XCTestExpectation(description: "Get Milestone to Project Relationship")

        var project: Project?
        if usingObjectToRelationshipMethod {
            milestone.project(objectAPI) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.project(milestone) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(project)

        if let project = project {
            XCTAssertEqual(project.id, milestone.projectId)
        }

        return project
    }

    // MARK: Plan

    @discardableResult func assertGetPlanToAssignedtoRelationship(_ plan: Plan, usingObjectToRelationshipMethod: Bool = false) -> User? {

        let expectation = XCTestExpectation(description: "Get Plan to Assignedto (User) Relationship")

        var assignedto: User?
        if usingObjectToRelationshipMethod {
            plan.assignedto(objectAPI) { (outcome) in
                assignedto = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.assignedto(plan) { (outcome) in
                assignedto = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let assignedtoId = plan.assignedtoId {
            XCTAssertNotNil(assignedto)
            if let assignedto = assignedto {
                XCTAssertEqual(assignedto.id, assignedtoId)
            }
        } else {
            XCTAssertNil(assignedto)
        }

        return assignedto
    }

    @discardableResult func assertGetPlanToCreatedByRelationship(_ plan: Plan, usingObjectToRelationshipMethod: Bool = false) -> User? {

        let expectation = XCTestExpectation(description: "Get Plan to CreatedBy (User) Relationship")

        var createdBy: User?
        if usingObjectToRelationshipMethod {
            plan.createdBy(objectAPI) { (outcome) in
                createdBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.createdBy(plan) { (outcome) in
                createdBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(createdBy)

        if let createdBy = createdBy {
            XCTAssertEqual(createdBy.id, plan.createdBy)
        }

        return createdBy
    }

    @discardableResult func assertGetPlanToMilestoneRelationship(_ plan: Plan, usingObjectToRelationshipMethod: Bool = false) -> Milestone? {

        let expectation = XCTestExpectation(description: "Get Plan to Milestone Relationship")

        var milestone: Milestone?
        if usingObjectToRelationshipMethod {
            plan.milestone(objectAPI) { (outcome) in
                milestone = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.milestone(plan) { (outcome) in
                milestone = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let milestoneId = plan.milestoneId {
            XCTAssertNotNil(milestone)
            if let milestone = milestone {
                XCTAssertEqual(milestone.id, milestoneId)
            }
        } else {
            XCTAssertNil(milestone)
        }

        return milestone
    }

    @discardableResult func assertGetPlanToProjectRelationship(_ plan: Plan, usingObjectToRelationshipMethod: Bool = false) -> Project? {

        let expectation = XCTestExpectation(description: "Get Plan to Project Relationship")

        var project: Project?
        if usingObjectToRelationshipMethod {
            plan.project(objectAPI) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.project(plan) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(project)

        if let project = project {
            XCTAssertEqual(project.id, plan.projectId)
        }

        return project
    }

    // MARK: Plan.Entry

    @discardableResult func assertGetPlanEntryToSuiteRelationship(_ planEntry: Plan.Entry, usingObjectToRelationshipMethod: Bool = false) -> Suite? {

        let expectation = XCTestExpectation(description: "Get Plan.Entry to Suite Relationship")

        var suite: Suite?
        if usingObjectToRelationshipMethod {
            planEntry.suite(objectAPI) { (outcome) in
                suite = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.suite(planEntry) { (outcome) in
                suite = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(suite)
        if let suite = suite {
            XCTAssertEqual(suite.id, planEntry.suiteId)
        }

        return suite
    }

    // MARK: Result

    @discardableResult func assertGetResultToAssignedtoRelationship(_ result: Result, usingObjectToRelationshipMethod: Bool = false) -> User? {

        let expectation = XCTestExpectation(description: "Get Result to Assignedto (User) Relationship")

        var assignedto: User?
        if usingObjectToRelationshipMethod {
            result.assignedto(objectAPI) { (outcome) in
                assignedto = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.assignedto(result) { (outcome) in
                assignedto = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let assignedtoId = result.assignedtoId {
            XCTAssertNotNil(assignedto)
            if let assignedto = assignedto {
                XCTAssertEqual(assignedto.id, assignedtoId)
            }
        } else {
            XCTAssertNil(assignedto)
        }

        return assignedto
    }

    @discardableResult func assertGetResultToCreatedByRelationship(_ result: Result, usingObjectToRelationshipMethod: Bool = false) -> User? {

        let expectation = XCTestExpectation(description: "Get Result to CreatedBy (User) Relationship")

        var createdBy: User?
        if usingObjectToRelationshipMethod {
            result.createdBy(objectAPI) { (outcome) in
                createdBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.createdBy(result) { (outcome) in
                createdBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(createdBy)

        if let createdBy = createdBy {
            XCTAssertEqual(createdBy.id, result.createdBy)
        }

        return createdBy
    }

    @discardableResult func assertGetResultToStatusRelationship(_ result: Result, usingObjectToRelationshipMethod: Bool = false) -> Status? {

        let expectation = XCTestExpectation(description: "Get Result to Status Relationship")

        var status: Status?
        if usingObjectToRelationshipMethod {
            result.status(objectAPI) { (outcome) in
                status = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.status(result) { (outcome) in
                status = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let statusId = result.statusId {
            XCTAssertNotNil(status)
            if let status = status {
                XCTAssertEqual(status.id, statusId)
            }
        } else {
            XCTAssertNil(status)
        }

        return status
    }

    @discardableResult func assertGetResultToTestRelationship(_ result: Result, usingObjectToRelationshipMethod: Bool = false) -> Test? {

        let expectation = XCTestExpectation(description: "Get Result to Test Relationship")

        var test: Test?
        if usingObjectToRelationshipMethod {
            result.test(objectAPI) { (outcome) in
                test = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.test(result) { (outcome) in
                test = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(test)

        if let test = test {
            XCTAssertEqual(test.id, result.testId)
        }

        return test
    }

    // MARK: ResultField

    @discardableResult func assertGetResultFieldToTemplatesRelationship(_ resultField: ResultField, usingObjectToRelationshipMethod: Bool = false) -> [Template]? {

        let expectation = XCTestExpectation(description: "Get ResultField to Templates Relationship")

        var templates: [Template]?
        if usingObjectToRelationshipMethod {
            resultField.templates(objectAPI) { (outcome) in
                templates = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.templates(resultField) { (outcome) in
                templates = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(templates)

        if let templates = templates {
            XCTAssertEqual(templates.count, resultField.templateIds.count)
            for templateId in resultField.templateIds {
                XCTAssertEqual(templates.filter({ $0.id == templateId }).count, 1)
            }
        }

        return templates
    }

    // MARK: Run

    @discardableResult func assertGetRunToAssignedtoRelationship(_ run: Run, usingObjectToRelationshipMethod: Bool = false) -> User? {

        let expectation = XCTestExpectation(description: "Get Run to Assignedto (User) Relationship")

        var assignedto: User?
        if usingObjectToRelationshipMethod {
            run.assignedto(objectAPI) { (outcome) in
                assignedto = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.assignedto(run) { (outcome) in
                assignedto = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let assignedtoId = run.assignedtoId {
            XCTAssertNotNil(assignedto)
            if let assignedto = assignedto {
                XCTAssertEqual(assignedto.id, assignedtoId)
            }
        } else {
            XCTAssertNil(assignedto)
        }

        return assignedto
    }

    @discardableResult func assertGetRunToConfigurationsRelationship(_ run: Run, usingObjectToRelationshipMethod: Bool = false) -> [Configuration]? {

        let expectation = XCTestExpectation(description: "Get Run to Configurations Relationship")

        var configurations: [Configuration]?
        if usingObjectToRelationshipMethod {
            run.configurations(objectAPI) { (outcome) in
                configurations = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.configurations(run) { (outcome) in
                configurations = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let runConfigIds = run.configIds {
            XCTAssertNotNil(configurations)
            if let configurations = configurations {
                XCTAssertEqual(configurations.count, runConfigIds.count)
                for id in runConfigIds {
                    XCTAssertEqual(configurations.filter({ $0.id == id }).count, 1)
                }
            }
        } else {
            XCTAssertNil(configurations)
        }

        return configurations
    }

    @discardableResult func assertGetRunToCreatedByRelationship(_ run: Run, usingObjectToRelationshipMethod: Bool = false) -> User? {

        let expectation = XCTestExpectation(description: "Get Run to CreatedBy (User) Relationship")

        var createdBy: User?
        if usingObjectToRelationshipMethod {
            run.createdBy(objectAPI) { (outcome) in
                createdBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.createdBy(run) { (outcome) in
                createdBy = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(createdBy)

        if let createdBy = createdBy {
            XCTAssertEqual(createdBy.id, run.createdBy)
        }

        return createdBy
    }

    @discardableResult func assertGetRunToMilestoneRelationship(_ run: Run, usingObjectToRelationshipMethod: Bool = false) -> Milestone? {

        let expectation = XCTestExpectation(description: "Get Run to Milestone Relationship")

        var milestone: Milestone?
        if usingObjectToRelationshipMethod {
            run.milestone(objectAPI) { (outcome) in
                milestone = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.milestone(run) { (outcome) in
                milestone = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let milestoneId = run.milestoneId {
            XCTAssertNotNil(milestone)
            if let milestone = milestone {
                XCTAssertEqual(milestone.id, milestoneId)
            }
        } else {
            XCTAssertNil(milestone)
        }

        return milestone
    }

    @discardableResult func assertGetRunToPlanRelationship(_ run: Run, usingObjectToRelationshipMethod: Bool = false) -> Plan? {

        let expectation = XCTestExpectation(description: "Get Run to Plan Relationship")

        var plan: Plan?
        if usingObjectToRelationshipMethod {
            run.plan(objectAPI) { (outcome) in
                plan = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.plan(run) { (outcome) in
                plan = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let planId = run.planId {
            XCTAssertNotNil(plan)
            if let plan = plan {
                XCTAssertEqual(plan.id, planId)
            }
        } else {
            XCTAssertNil(plan)
        }

        return plan
    }

    @discardableResult func assertGetRunToProjectRelationship(_ run: Run, usingObjectToRelationshipMethod: Bool = false) -> Project? {

        let expectation = XCTestExpectation(description: "Get Run to Project Relationship")

        var project: Project?
        if usingObjectToRelationshipMethod {
            run.project(objectAPI) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.project(run) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(project)

        if let project = project {
            XCTAssertEqual(project.id, run.projectId)
        }

        return project
    }

    @discardableResult func assertGetRunToSuiteRelationship(_ run: Run, usingObjectToRelationshipMethod: Bool = false) -> Suite? {

        let expectation = XCTestExpectation(description: "Get Run to Suite Relationship")

        var suite: Suite?
        if usingObjectToRelationshipMethod {
            run.suite(objectAPI) { (outcome) in
                suite = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.suite(run) { (outcome) in
                suite = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let suiteId = run.suiteId {
            XCTAssertNotNil(suite)
            if let suite = suite {
                XCTAssertEqual(suite.id, suiteId)
            }
        } else {
            XCTAssertNil(suite)
        }

        return suite
    }

    // MARK: Section

    @discardableResult func assertGetSectionToParentRelationship(_ section: Section, usingObjectToRelationshipMethod: Bool = false) -> Section? {

        let expectation = XCTestExpectation(description: "Get Section to Parent (Section) Relationship")

        var parent: Section?
        if usingObjectToRelationshipMethod {
            section.parent(objectAPI) { (outcome) in
                parent = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.parent(section) { (outcome) in
                parent = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let parentId = section.parentId {
            XCTAssertNotNil(parent)
            if let parent = parent {
                XCTAssertEqual(parent.id, parentId)
            }
        } else {
            XCTAssertNil(parent)
        }

        return parent
    }

    @discardableResult func assertGetSectionToSuiteRelationship(_ section: Section, usingObjectToRelationshipMethod: Bool = false) -> Suite? {

        let expectation = XCTestExpectation(description: "Get Section to Suite Relationship")

        var suite: Suite?
        if usingObjectToRelationshipMethod {
            section.suite(objectAPI) { (outcome) in
                suite = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.suite(section) { (outcome) in
                suite = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let suiteId = section.suiteId {
            XCTAssertNotNil(suite)
            if let suite = suite {
                XCTAssertEqual(suite.id, suiteId)
            }
        } else {
            XCTAssertNil(suite)
        }

        return suite
    }

    // MARK: Suite

    @discardableResult func assertGetSuiteToProjectRelationship(_ suite: Suite, usingObjectToRelationshipMethod: Bool = false) -> Project? {

        let expectation = XCTestExpectation(description: "Get Suite to Project Relationship")

        var project: Project?
        if usingObjectToRelationshipMethod {
            suite.project(objectAPI) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.project(suite) { (outcome) in
                project = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(project)

        if let project = project {
            XCTAssertEqual(project.id, suite.projectId)
        }

        return project
    }

    // MARK: Test

    @discardableResult func assertGetTestToAssignedtoRelationship(_ test: Test, usingObjectToRelationshipMethod: Bool = false) -> User? {

        let expectation = XCTestExpectation(description: "Get Test to Assignedto (User) Relationship")

        var assignedto: User?
        if usingObjectToRelationshipMethod {
            test.assignedto(objectAPI) { (outcome) in
                assignedto = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.assignedto(test) { (outcome) in
                assignedto = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let assignedtoId = test.assignedtoId {
            XCTAssertNotNil(assignedto)
            if let assignedto = assignedto {
                XCTAssertEqual(assignedto.id, assignedtoId)
            }
        } else {
            XCTAssertNil(assignedto)
        }

        return assignedto
    }

    @discardableResult func assertGetTestToCaseRelationship(_ test: Test, usingObjectToRelationshipMethod: Bool = false) -> Case? {

        let expectation = XCTestExpectation(description: "Get Test to Case Relationship")

        var `case`: Case?
        if usingObjectToRelationshipMethod {
            test.`case`(objectAPI) { (outcome) in
                `case` = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.`case`(test) { (outcome) in
                `case` = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(`case`)

        if let `case` = `case` {
            XCTAssertEqual(`case`.id, test.caseId)
        }

        return `case`
    }

    @discardableResult func assertGetTestToMilestoneRelationship(_ test: Test, usingObjectToRelationshipMethod: Bool = false) -> Milestone? {

        let expectation = XCTestExpectation(description: "Get Test to Milestone Relationship")

        var milestone: Milestone?
        if usingObjectToRelationshipMethod {
            test.milestone(objectAPI) { (outcome) in
                milestone = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.milestone(test) { (outcome) in
                milestone = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        if let milestoneId = test.milestoneId {
            XCTAssertNotNil(milestone)
            if let milestone = milestone {
                XCTAssertEqual(milestone.id, milestoneId)
            }
        } else {
            XCTAssertNil(milestone)
        }

        return milestone
    }

    @discardableResult func assertGetTestToPriorityRelationship(_ test: Test, usingObjectToRelationshipMethod: Bool = false) -> Priority? {

        let expectation = XCTestExpectation(description: "Get Test to Priority Relationship")

        var priority: Priority?
        if usingObjectToRelationshipMethod {
            test.priority(objectAPI) { (outcome) in
                priority = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.priority(test) { (outcome) in
                priority = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(priority)

        if let priority = priority {
            XCTAssertEqual(priority.id, test.priorityId)
        }

        return priority
    }

    @discardableResult func assertGetTestToRunRelationship(_ test: Test, usingObjectToRelationshipMethod: Bool = false) -> Run? {

        let expectation = XCTestExpectation(description: "Get Test to Run Relationship")

        var run: Run?
        if usingObjectToRelationshipMethod {
            test.run(objectAPI) { (outcome) in
                run = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.run(test) { (outcome) in
                run = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(run)

        if let run = run {
            XCTAssertEqual(run.id, test.runId)
        }

        return run
    }

    @discardableResult func assertGetTestToStatusRelationship(_ test: Test, usingObjectToRelationshipMethod: Bool = false) -> Status? {

        let expectation = XCTestExpectation(description: "Get Test to Status Relationship")

        var status: Status?
        if usingObjectToRelationshipMethod {
            test.status(objectAPI) { (outcome) in
                status = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.status(test) { (outcome) in
                status = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(status)
        if let status = status {
            XCTAssertEqual(status.id, test.statusId)
        }

        return status
    }

    @discardableResult func assertGetTestToTemplateRelationship(_ test: Test, usingObjectToRelationshipMethod: Bool = false) -> Template? {

        let expectation = XCTestExpectation(description: "Get Test to Template Relationship")

        var template: Template?
        if usingObjectToRelationshipMethod {
            test.template(objectAPI) { (outcome) in
                template = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.template(test) { (outcome) in
                template = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(template)

        if let template = template {
            XCTAssertEqual(template.id, test.templateId)
        }

        return template
    }

    @discardableResult func assertGetTestToTypeRelationship(_ test: Test, usingObjectToRelationshipMethod: Bool = false) -> CaseType? {

        let expectation = XCTestExpectation(description: "Get Test to Type (CaseType) Relationship")

        var type: CaseType?
        if usingObjectToRelationshipMethod {
            test.type(objectAPI) { (outcome) in
                type = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        } else {
            objectAPI.type(test) { (outcome) in
                type = self.assertOutcomeSucceeded(outcome)
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: timeout)

        XCTAssertNotNil(type)

        if let type = type {
            XCTAssertEqual(type.id, test.typeId)
        }

        return type
    }

}
