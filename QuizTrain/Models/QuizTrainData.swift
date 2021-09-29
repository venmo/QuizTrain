/// Data structure that contains the whole data from a QuizTrain project. It can serialize and write/read data from file all at once
public struct QuizTrainData {
    public let project: QuizTrain.Project
    public let suites: [QuizTrain.Suite]
    public let sections: [QuizTrain.Section]
    public let cases: [QuizTrain.Case]
    public let statuses: [QuizTrain.Status]
    public let users: [QuizTrain.User]
    public let currentUser: QuizTrain.User
    
    public init(project: QuizTrain.Project, suites: [QuizTrain.Suite], sections: [QuizTrain.Section], cases: [QuizTrain.Case], statuses: [QuizTrain.Status], users: [QuizTrain.User], currentUser: QuizTrain.User) {
        self.project = project
        self.suites = suites
        self.sections = sections
        self.cases = cases
        self.statuses = statuses
        self.users = users
        self.currentUser = currentUser
    }
}

// MARK: - JSON Keys

extension QuizTrainData {
    
    enum JSONKeys: JSONKey {
        case project
        case suites
        case sections
        case cases
        case statuses
        case users
        case currentUser
    }
    
}

// MARK: - Serialization

extension QuizTrainData: JSONDeserializable {

    init?(json: JSONDictionary) {

        guard let projectJson = json[JSONKeys.project.rawValue] as? JSONDictionary,
              let currentUserJson = json[JSONKeys.currentUser.rawValue] as? JSONDictionary,
              let usersJson = json[JSONKeys.users.rawValue] as? [JSONDictionary],
              let suitesJson = json[JSONKeys.suites.rawValue] as? [JSONDictionary],
              let sectionsJson = json[JSONKeys.sections.rawValue] as? [JSONDictionary],
              let casesJson = json[JSONKeys.cases.rawValue] as? [JSONDictionary],
              let statusesJson = json[JSONKeys.statuses.rawValue] as? [JSONDictionary]
        else {
            return nil
        }

        let project = QuizTrain.Project.init(json: projectJson)!
        let currentUser = QuizTrain.User.init(json: currentUserJson)!
        let users = usersJson.map({ User.init(json: $0)! })
        let suites = suitesJson.map({ Suite.init(json: $0)! })
        let sections = sectionsJson.map({ Section.init(json: $0)! })
        let cases = casesJson.map({ Case.init(json: $0)! })
        let statuses = statusesJson.map({ Status.init(json: $0)! })
        
        self.init(project: project, suites: suites, sections: sections, cases: cases, statuses: statuses, users: users, currentUser: currentUser)

    }
}

extension QuizTrainData: JSONSerializable {
    public func serialized() -> JSONDictionary {
        return [JSONKeys.project.rawValue: project.serialized(),
                JSONKeys.suites.rawValue: suites.map({ $0.serialized() }),
                JSONKeys.sections.rawValue: sections.map({ $0.serialized() }),
                JSONKeys.statuses.rawValue: statuses.map({ $0.serialized() }),
                JSONKeys.cases.rawValue: cases.map({ $0.serialized() }),
                JSONKeys.users.rawValue: users.map({ $0.serialized() }),
                JSONKeys.currentUser.rawValue: currentUser.serialized()
        ]
    }
}

extension QuizTrainData {
    public static func writeToFile(atPath: URL, quizTrainData: QuizTrainData) {
        if !FileManager.default.fileExists(atPath: atPath.path) {
          FileManager.default.createFile(atPath: atPath.path, contents: nil)
        }
        do {
            let json = try JSONSerialization.data(withJSONObject: quizTrainData.serialized(), options: .fragmentsAllowed)
            try json.write(to: atPath)
        } catch {
            print("QuizTrain Data Error: Cannot write to file at path: \(atPath)")
            return
        }
    }
    
    public static func readFromFile(atPath: URL) -> QuizTrainData? {
        guard let data = try? Data.init(contentsOf: atPath) else {
            print("QuizTrain Data Error: Cannot write to file at path: \(atPath)")
            return nil
        }
        guard let json = try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed) as? JSONDictionary else {
            print("QuizTrain Data Error: Cannot convert data to json object")
            return nil
        }
        return QuizTrainData.init(json: json)
    }
}
