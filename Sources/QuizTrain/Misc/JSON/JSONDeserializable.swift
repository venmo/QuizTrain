/*
 Provides methods to deserialize JSON into an object or objects.
 */
protocol JSONDeserializable {
    static func deserialized<ObjectType: JSONDeserializable>(_ json: [JSONDictionary]) -> [ObjectType]?
    static func deserialized<ObjectType: JSONDeserializable>(_ json: JSONDictionary) -> ObjectType?
    init?(json: JSONDictionary)
}

extension JSONDeserializable {

    /*
     Initializes and returns multiple objects of ObjectType which conform to
     JSONDeserializable.
     */
    static func deserialized<ObjectType: JSONDeserializable>(_ json: [JSONDictionary]) -> [ObjectType]? {
        var objects = [ObjectType]()
        for item in json {
            guard let object: ObjectType = deserialized(item) else {
                return nil
            }
            objects.append(object)
        }
        return objects
    }

    /*
     Initializes and returns a single object of ObjectType which conforms to
     JSONDeserializable.
     */
    static func deserialized<ObjectType: JSONDeserializable>(_ json: JSONDictionary) -> ObjectType? {
        return ObjectType(json: json)
    }

}
