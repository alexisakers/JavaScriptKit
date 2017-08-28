/**
 *  JSBridge
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// A concrete JavaScript expression that returns the value of a variable of the current JavaScript
/// `this`.
///
/// For instance, to get the address of the page:
///
/// ~~~swift
/// let addr = JSGlobal<String>("addr")
/// // equivalent to the JS script `this.addr;`
/// ~~~
///
/// Instances of this class are specialized with the `ReturnType` generic parameter. It must be set
/// to the return type of the JavaScript variable to resolve. Check the documentation of the
/// JavaScript variable to know what to set the parameter to.
///
/// `ReturnType` must be a compatible type. Compatible types include:
/// - Primitive values (`JSPrimitiveType`)
/// - Enum cases with a primitive `RawValue`
/// - Objects (`JSObject`)
/// - Arrays of primitive values
/// - Arrays of enum cases with a primitive `RawValue`
/// - Arrays of objects.
///

public class JSGlobal<ReturnType>: JSExpression<ReturnType> {

    ///
    /// The name of the variable to resolve.
    ///
    /// It must be a member of the current JavaScript `this`.
    ///

    public let variableName: String

    ///
    /// Creates a new variable description.
    ///
    /// - parameter variableName: The name of the variable to resolve. It must be a member of the
    /// current JavaScript `this`.
    ///

    public init(_ variableName: String, _ arguments: JSConvertible...) {
        self.variableName = variableName
    }

    public override var javaScriptString: String {
        return variableName
    }

}
