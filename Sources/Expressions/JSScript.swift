//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation

/**
 * A JavaScript expression that executes a user-defined script. This class allows you to
 * evaluate your own custom scripts.
 *
 * For instance, to return the text of the longest <p> node in the current document:
 *
 * ~~~swift
 * let javaScript = """
 * var longestInnerHTML = "";
 * var pTags = document.getElementsByTagName("p");
 *
 * for (var i = 0; i < pTags.length; i++) {
 *     var innerHTML = pTags[i].innerHTML;
 *
 *     if (innerHTML.length > longestInnerHTML.length) {
 *         longestInnerHTML = innerHTML;
 *     }
 * }
 *
 * longestInnerHTML;
 * """
 *
 * let findLongestText = JSScript<String>(javaScript)
 * // this is equivalent to running the script inside a browser's JavaScript console.
 * ~~~
 *
 * Instances of this class are specialized with the `T` generic parameter. It must be set to the
 * type of the last statement in your script. In the above example, `findLongestText` has a return
 * type of `String` because its last statement is a String (`longestInnerHTML`).
 *
 * `T` must be a `Decodable` type. This includes:
 *
 * - `JSVoid` for scripts that do not return a value
 * - Primitive values (Strings, Numbers, Booleans, ...)
 * - Decodable enumerations
 * - Objects decodable from JSON
 * - Arrays of primitive values
 * - Arrays of enumeration cases
 * - Arrays of objects
 * - Native dictionaries
 */

public final class JSScript<T>: JSExpression where T: Decodable {
    public typealias ReturnType = T

    /// The text of the script to execute.
    public let javaScriptString: String

    /**
     * Creates a new custom script description with the script to execute.
     *
     * - parameter javaScriptString: The script to run when evaluating this expression. It will
     * be ran without modifications, so make sure to check for syntax errors and escape strings if
     * necessary before creating the expression.
     */

    public init(_ javaScriptString: String) {
        self.javaScriptString = javaScriptString
    }

    /// Creates the JavaScript text of the expression.
    public func makeExpressionString() -> String {
        return javaScriptString
    }

}
