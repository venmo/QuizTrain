# Example

This is an example iOS project showing how you can integrate [QuizTrain](https://github.com/venmo/QuizTrain) with your unit tests and user interface tests.

## License

The Example project is open source software released under the MIT License. See the [LICENSE](LICENSE) file for details.

## Prerequisites

- Install [Xcode](https://developer.apple.com/xcode/).
- Install [Carthage](https://github.com/Carthage/Carthage#installing-carthage).

## Setup

Before building and running tests there are some placeholder values you must update in code marked with Swift `#error` macros. After updating them comment out the macros.

- `TestManager.swift`
    - Update `let objectAPI = QuizTrain.ObjectAPI(...)` with valid credentials and other info for your TestRail instance.
    - Update `QuizTrainProject.populatedProject(...)` with a projectId from your TestRail instance.
- `ExampleTests.swift`
    - Update all of the placeholder case IDs with real case IDs for your project.
- `ExampleUITests.swift`
    - Update all of the placeholder case IDs with real case IDs for your project.

If you'd like you can create a temporary project on your TestRail instance and use that to test with. Select *Use multiple test suites to manage cases* when creating the project and then add 16 test cases.

## Building and Testing

    cd ../Example
    carthage checkout --use-submodules
    open Example.xcodeproj

Select the `Example` scheme and type `Command-U` to build Example and run unit tests and user interface tests. If everything goes well you should see a URL in the console to a closed test plan (one for unit tests, another for user interface tests) containing your results on TestRail. You should also see them appear as *QuizTrain Test Results* under *Test Runs & Results* in your project.
