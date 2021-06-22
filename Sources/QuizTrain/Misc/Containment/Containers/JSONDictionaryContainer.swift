import Foundation

/*
 Provides a container to store arbitrary JSON dictionaries.
 */
struct JSONDictionaryContainer: JSONDeserializable, JSONSerializable {

    var json: JSONDictionary

    init(json: JSONDictionary) {
        self.json = json
    }

    func serialized() -> JSONDictionary {
        return json
    }

}

extension JSONDictionaryContainer: Equatable {

    static func==(lhs: JSONDictionaryContainer, rhs: JSONDictionaryContainer) -> Bool {

        let lhsSerialized = lhs.serialized()
        let rhsSerialized = rhs.serialized()

        // Attempt to cast to NSDictionary to rely on its isEqual code.
        if lhsSerialized as NSDictionary == rhsSerialized as NSDictionary {
            return true
        }

        return false
    }

}
