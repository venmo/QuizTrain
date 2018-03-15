import Foundation

/*
 Asynchronous subclass of Operation providing state tracking with KVO. Subclass
 this class to implement custom asynchronous operations.
 */
class AsyncOperation: Operation {

    enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }

    private var _state = State.ready
    private let stateLock = NSLock() // atomic lock
    var state: State {
        get {
            stateLock.lock()
            let value = _state
            stateLock.unlock()
            return value
        }
        set {
            willChangeValue(forKey: newValue.rawValue)
            stateLock.lock()
            _state = newValue
            stateLock.unlock()
            didChangeValue(forKey: newValue.rawValue)
        }
    }

    override var isAsynchronous: Bool { return true }
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }

}
