/*
 Container for outcomes. For a .succeeded outcome which does not pass an object
 ensure the Succeeded generic is an optional (e.g. Void?) and use
 Outcome.succeeded(nil).
 */
public enum Outcome<Succeeded, Failed: Error> {
    case succeeded(Succeeded)
    case failed(Failed)
}
