/**
 *  JSBridge
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// A class to customize fatal error closures.
///
/// Only use within this file and inside of tests to assert that `fail` gets called.
///

class FatalErrorManager {

    /// A fatal error.
    typealias FatalError = (@autoclosure () -> String, StaticString, UInt) -> Any

    /// The current fatal error closure.
    static var fatalErrorClosure = FatalErrorManager.defaultFatalErrorClosure

    /// The default fatal error closure.
    private static let defaultFatalErrorClosure: FatalError = Swift.fatalError

    /// Sets a new fatal error closure.
    static func replaceFatalError(closure: @escaping FatalError) {
        fatalErrorClosure = closure
    }

    /// Restores the default fatal error closure.
    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }

}

/// Runs the run loop forever Run after a function that can return `Never`.
internal func stop() -> Never {
    while true {
        RunLoop.current.run()
    }
}

/// Stops the program with an error message.
internal func fail(_ message: @autoclosure () -> String,
                   _ file: StaticString = #file,
                   _ line: UInt = #line) -> Never {
    _ = FatalErrorManager.fatalErrorClosure(message(), file, line)
    stop()
}

/// Stops the program when a function is unavailable.
internal func unavailable(_ function: String = #function,
                          _ file: String = #file,
                          _ line: Int = #line) -> Never {
    let message = "\(file):\(line) — \(function) is not available."
    fail(message)
}
