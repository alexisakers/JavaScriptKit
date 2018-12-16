//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation

/**
 * A JavaScript expression that executes a function in the current JavaScript `this`. The
 * function variable is referenced by a key path relative to the current `this`.
 *
 * For instance, to present an alert:
 *
 * ~~~swift
 * let alert = JSFunction<JSVoid>("window.alert", arguments: "Hello from Swift!")
 * // equivalent to the JS script: `this.window.alert("Hello from Swift!");`
 * ~~~
 *
 * Instances of this class are specialized with the `T` generic parameter. It must be set to the
 * return type of the JavaScript function to execute. Check the documentation of the JavaScript
 * function to know what to set the parameter to.
 *
 * `T` must be a `Decodable` type. This includes:
 *
 * - `JSVoid` for functions that do not return a value
 * - Primitive values (Strings, Numbers, Booleans, ...)
 * - Decodable enumerations
 * - Objects decodable from JSON
 * - Arrays of primitive values
 * - Arrays of enumeration cases
 * - Arrays of objects
 * - Native dictionaries
 */

public final class JSFunction<T>: JSExpression where T: Decodable {

    public typealias ReturnType = T

    /// The key path to the function to execute, relative the current `this` object tree.
    public let keyPath: String

    /// The arguments to pass to the function.
    public let arguments: [Encodable]

    /**
     * Creates a new method description.
     *
     * - parameter keyPath: A dot-separated key path to the function to execute, relative the
     * current `this` object tree.
     * - parameter arguments: The arguments to pass to the function. You can omit this paramter if
     * the JavaScript function you are calling takes no arguments.
     *
     * For instance, to present an alert:
     *
     * ~~~swift
     * let alert = JSFunction<JSVoid>("window.alert", arguments: "Hello from Swift!")
     * // equivalent to the JS script: `this.window.alert("Hello from Swift!");`
     * ~~~
     */

    public init(_ keyPath: String, arguments: Encodable...) {
        self.keyPath = keyPath
        self.arguments = arguments
    }

    /// Creates the JavaScript text of the expression.
    public func makeExpressionString() throws -> String {
        let encoder = JavaScriptEncoder()

        let argumentsList = try arguments.reduce(into: "") { partialResult, argument in
            let jsArgument = try encoder.encode(argument)
            partialResult += partialResult.isEmpty ? "" : ", "
            partialResult += jsArgument
        }

        return "this.\(keyPath)" + "(" + argumentsList + ");"
    }

}
