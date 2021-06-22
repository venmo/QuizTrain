import Foundation

class GetConfigurationGroupsOperation: AsyncOperation {

    // MARK: Properties

    private(set) weak var api: ObjectAPI?
    let projectId: Project.Id

    // MARK: Init

    init(api: ObjectAPI, projectId: Project.Id) {
        self.api = api
        self.projectId = projectId
    }

    // MARK: Execution

    override func start() {

        guard isCancelled == false else {
            state = .finished
            return
        }

        guard let api = api else {
            cancel()
            state = .finished
            return
        }

        state = .executing

        api.getConfigurationGroups(inProjectWithId: projectId) { [weak self] (outcome) in
            self?.outcome = outcome
            self?.state = .finished
        }
    }

    // MARK: Completion

    private(set) var outcome: Outcome<[ConfigurationGroup], ObjectAPI.GetError>?

}
