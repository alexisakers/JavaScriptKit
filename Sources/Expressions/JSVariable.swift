//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation

/**
 * A JavaScript expression that returns the value of a variable in the current JavaScript
 * `this`. The variable is referenced by a key path relative to the current `this`.
 *
 * For instance, to get the title of the current document:
 *
 * ~~~swift
 * let title = JSVariable<String>("document.title")
 * // equivalent to the JS script: `this.document.title;`
 * ~~~
 *
 * Instances of this class are specialized with the `T` generic parameter. It must be set to the
 * type of the JavaScript variable to query. Check the documentation of the JavaScript variable
 * to know what to set the parameter to.
 *
 * `T` must be a `Decodable` type. This includes:
 *
 * - Primitive values (Strings, Numbers, Booleans, ...)
 * - Decodable enumerations
 * - Objects decodable from JSON
 * - Arrays of primitive values
 * - Arrays of enumeration cases
 * - Arrays of objects
 * - Native dictionaries
 */

public final class JSVariable<T>: JSExpression where T: Decodable {
    public typealias ReturnType = T

    /// The path to the variable, relative to the current `this` object tree.
    public let keyPath: String

    /**
     * Creates a new JavaScript variable description.
     *
     * - parameter keyPath: The dot-separated path to the variable, relative to the current `this`
     * object tree.
     *
     * For instance, to get the title of the current document:
     *
     * ~~~swift
     * let title = JSVariable<String>("document.title")
     * // equivalent to the JS script: `this.document.title;`
     * ~~~
     */

    public init(_ keyPath: String) {
        self.keyPath = keyPath
    }

    /// Creates the JavaScript text of the expression.
    public func makeExpressionString() -> String {
        return "this.\(keyPath);"
    }

}
