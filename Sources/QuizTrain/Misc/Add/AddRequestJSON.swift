/*
 Returns JSON for an add request.
 */
protocol AddRequestJSON {
    var addRequestJSON: JSONDictionary { get }
}

extension AddRequestJSON where Self: JSONSerializable & AddRequestJSONKeys {

    var addRequestJSON: JSONDictionary {
        var json = serialized()
        json = json.filter { pair in addRequestJSONKeys.contains(pair.key) }
        return json
    }

}
