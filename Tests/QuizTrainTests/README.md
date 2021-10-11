# QuizTrainTests 📝🚆✅

QuizTrainTests provides unit tests and systems tests against a real TestRail instance. It is advised that you backup your instance fully before running tests and verify that the backup is valid. For more details see comments and code in [ObjectAPITests.swift](Network/ObjectAPITests.swift).

## Running Tests

1. Update [`TestCredentials.json`](Testing%20Misc/TestCredentials.json) accordingly.
    - *The `username` user must have permissions to create and delete projects.*
2. Select a scheme.
    - *Apple does not support unit testing on watchOS.*
3. Select a  target to run tests on.
    - *It must have full network connectivity to your TestRail instance.*
4. In the Xcode menu: `Product -> Test`

For [ObjectAPITests.swift](Network/ObjectAPITests.swift) to run you must set any custom **Case Fields** and **Result Fields** in your TestRail instance either as not-required, or required with a default value, for the duration of testing. Otherwise tests might not be able to setup necessary test projects since they do not know of required customizations specific to your instance.

## NewCaseField Tests

The following NewCaseField tests in [ObjectAPITests](Network/ObjectAPITests.swift) are disabled by default in all testing schemes since they cannot be deleted using the API after tests complete:

    testAddCheckboxCaseField()
    testAddDateCaseField()
    testAddDropdownCaseField()
    testAddIntegerCaseField()
    testAddMilestoneCaseField()
    testAddMultiselectCaseField()
    testAddStepsCaseField()
    testAddStringCaseField()
    testAddTextCaseField()
    testAddURLCaseField()
    testAddUserCaseField()

If you run or enable these tests you must manually delete the Case Fields they create in your TestRail administration dashboard. Their system name will be prefixed with `quiztraintests_` followed by eight random letters a-z, and their label will be the name of the test method.

Note `testAddStepsCaseField()` will fail with a 400 error if you have already created a Case Field of type `NewCaseFieldType.steps`. As of writing only one of that type is allowed across your entire TestRail instance.
