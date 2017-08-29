/**
 *  JSBridge
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// A concrete JavaScript expression that executes a user-defined script. This class allows you to
/// evaluate your own scripts.
///
/// For instance, to return the text of the longest <p> node in the current document:
///
/// ~~~swift
/// let javaScript = """
/// var longestInnerHTML = "";
/// var pTags = document.getElementsByTagName("p");
///
/// for (var i = 0; i < pTags.length; i++) {
///     var innerHTML = pTags[i].innerHTML;
///
///     if (innerHTML.length > longestInnerHTML.length) {
///         longestInnerHTML = innerHTML;
///     }
/// }
///
/// longestInnerHTML;
/// """
///
/// let findLongestText = JSScript<String>(javaScript)
/// // this is equivalent to running the script inside a browser's JavaScript console.
/// ~~~
///
/// Instances of this class are specialized with the `T` generic parameter. It must be set to the
/// type of the last statement in your script. In the above example, `findLongestText` has a return
/// type of `String` because its last statement is a String (`longestInnerHTML`).
///
/// `T` must be a compatible type. Compatible types include:
/// - `Void`
/// - Primitive values (`JSPrimitiveType`)
/// - Enum cases with a primitive `RawValue`
/// - Objects (`JSObject`)
/// - Arrays of primitive values
/// - Arrays of enum cases with a primitive `RawValue`
/// - Arrays of objects.
///

public final class JSScript<T>: JSExpression {

    public typealias ReturnType = T
    public let javaScriptString: String

    ///
    /// Creates a new custom script description with the script to execute.
    ///
    /// - parameter javaScriptString: The script to run when evaluating this expression. It will
    /// be ran as is, make sure to check for syntax errors before creating the expression.
    ///

    public init(_ javaScriptString: String) {
        self.javaScriptString = javaScriptString
    }

    public func makeExpressionString() -> String {
        return javaScriptString
    }

}
