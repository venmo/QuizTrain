# Errors

## Handling

It is up to the consumer of QuizTrain to handle all errors. However `ObjectAPI` will handle 429 Too Many Request (rate limit reached) errors automatically unless you set `.handle429TooManyRequestErrors` to `false`.

Errors are defined here:

- [API.swift](QuizTrain/Network/API.swift) in the *Errors* section.
- [ObjectAPI.swift](QuizTrain/Network/ObjectAPI.swift) in the *Errors* section.

You can handle errors two ways:

1. Simply by using `error.debugDescription` to print a rich description of an error.
    - *Provided by errors conforming to `CustomDebugStringConvertible`.*
2. Advanced by `switch`'ing on an error.

Simple is best for debugging and logging. Advanced is best for everything else.

All API and ObjectAPI errors conform to [`CustomDebugStringConvertible`](https://developer.apple.com/documentation/swift/customdebugstringconvertible). If these errors print a `URLRequest` through this protocol then its `AUTHORIZATION` header will be stripped to avoid exposing your TestRail credentials.

### Example

This shows both simple and advanced error handling when adding a new Case to a Section.

#### Setup

    let newCase = NewCase(estimate: nil, milestoneId: nil, priorityId: nil, refs: nil, templateId: nil, title: "New Case Title", typeId: nil, customFields: nil)

#### Simple

    objectAPI.addCase(newCase, toSectionWithId: 5) { (outcome) in
        switch outcome {
        case .failed(let error):
            print(error.debugDescription)
        case .succeeded(let `case`):
            print(`case`.title) // Do something with the newly created `case`.
        }
    }

#### Advanced

    objectAPI.addCase(newCase, toSectionWithId: 5) { (outcome) in
        switch outcome {
        case .failed(let error):
            switch error {
            case .apiError(let apiError): // API.RequestError
                switch apiError {
                case .error(let request, let error):
                    print(request)
                    print(error)
                case .invalidResponse(let request, let response):
                    print(request)
                    print(response)
                case .nilResponse(let request):
                    print(request)
                }
            case .dataProcessingError(let dataProcessingError): // ObjectAPI.DataProcessingError
                switch dataProcessingError {
                case .couldNotConvertDataToJSON(let data, let error):
                    print(data)
                    print(error)
                case .couldNotDeserializeFromJSON(let objectType, let json):
                    print(objectType)
                    print(json)
                case .invalidJSONFormat(let json):
                    print(json)
                }
            case .objectConversionError(let objectConversionError): // ObjectAPI.ObjectConversionError
                switch objectConversionError {
                case .couldNotConvertObjectsToData(let objects, let json, let error):
                    print(objects)
                    print(json)
                    print(error)
                case .couldNotConvertObjectToData(let object, let json, let error):
                    print(object)
                    print(json)
                    print(error)
                }
            case .statusCodeError(let statusCodeError): // ObjectAPI.StatusCodeError
                switch statusCodeError {
                case .clientError(let clientError): // ObjectAPI.ClientError
                    print(clientError.message)
                    print(clientError.statusCode)
                    print(clientError.requestResult.request)
                    print(clientError.requestResult.response)
                    print(clientError.requestResult.data)
                case .otherError(let otherError): // API.RequestResult
                    print(otherError.request)
                    print(otherError.response)
                    print(otherError.data)
                case .serverError(let serverError): // ObjectAPI.ServerError
                    print(serverError.message)
                    print(serverError.statusCode)
                    print(serverError.requestResult.request)
                    print(serverError.requestResult.response)
                    print(serverError.requestResult.data)
                }
            }
        case .succeeded(let `case`):
            print(`case`.title) // Do something with the newly created `case`.
        }
    }
