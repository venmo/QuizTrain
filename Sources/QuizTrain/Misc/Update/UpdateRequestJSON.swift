/*
 Returns JSON for an update request.
 */
protocol UpdateRequestJSON {
    var updateRequestJSON: JSONDictionary { get }
}

extension UpdateRequestJSON where Self: JSONSerializable & UpdateRequestJSONKeys {

    var updateRequestJSON: JSONDictionary {
        var json = serialized()
        json = json.filter { pair in updateRequestJSONKeys.contains(pair.key) }
        return json
    }

}
