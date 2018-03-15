/*
 Provides methods to serialize an object or objects into JSON.
 */
protocol JSONSerializable {
    static func serialized<ObjectType: JSONSerializable>(_ objects: [ObjectType]) -> [JSONDictionary]
    static func serialized<ObjectType: JSONSerializable>(_ object: ObjectType) -> JSONDictionary
    func serialized() -> JSONDictionary
}

extension JSONSerializable {

    /*
     Serializes an array of objects into JSONDictionary's.
     */
    static func serialized<ObjectType: JSONSerializable>(_ objects: [ObjectType]) -> [JSONDictionary] {
        var jsonArray: [JSONDictionary] = []
        for object in objects {
            jsonArray.append(ObjectType.serialized(object))
        }
        return jsonArray
    }

    /*
     Serializes an object into a JSONDictionary.
     */
    static func serialized<ObjectType: JSONSerializable>(_ object: ObjectType) -> JSONDictionary {
        return object.serialized()
    }

}
