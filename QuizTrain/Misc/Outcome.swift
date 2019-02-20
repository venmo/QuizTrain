/*
 Container for outcomes. For a .success outcome which does not pass an object
 ensure the Succeeded generic is an optional (e.g. Void?) and use
 Outcome.success(nil).

 A typealias is used to allow "Result" to be used as a TestRail model.
 */
public typealias Outcome = Swift.Result
