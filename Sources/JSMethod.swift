/**
 *  JSBridge
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// A concrete JavaScript expression that executes a function that belongs
/// to the prototype of a variable of the current JavaScript `this`.
///
/// For instance, to log a value to the console:
///
/// ~~~swift
/// let log = JSMethod<Void>("console", "log", "Hello from Swift!")
/// // equivalent to the JS script `this.console.log("Hello from Swift!");`
/// ~~~
///
/// Instances of this class are specialized with the `ReturnType` generic parameter.
/// It must be set to the return type of the JavaScript function to execute. Check the docs of
/// the JavaScript variable to know what to set the parameter to.
///
/// `ReturnType` must be a compatible type. Compatible types include:
/// - Primitive values (`JSPrimitiveType`)
/// - Enum cases with a primitive `RawValue`
/// - Objects (`JSObject`)
/// - Arrays of primitive values
/// - Arrays of enum cases with a primitive `RawValue`
/// - Arrays of objects.
///

public class JSMethod<ReturnType>: JSExpression<ReturnType> {
    
    ///
    /// The name of the variable that contains the requested function.
    ///
    /// It must be a member of the current JavaScript `this`.
    ///

    public let variableName: String

    /// The name of the method to execute.
    public let methodName: String

    /// The arguments to pass to the method.
    public let arguments: [JSConvertible]

    ///
    /// Creates a new method description.
    ///
    /// - parameter variableName: The name of the variable that contains the requested function.
    /// - parameter methodName: The name of the method to execute.
    /// - parameter arguments: The arguments to pass to the method.
    ///

    public init(_ variableName: String, _ methodName: String, _ arguments: JSConvertible...) {
        self.variableName = variableName
        self.methodName = methodName
        self.arguments = arguments
    }

    public override var javaScriptString: String {

        let argumentsList = arguments.reduce("") {
            partialResult, argument in

            let separator = partialResult.isEmpty ? "" : ", "
            return partialResult + separator + argument.jsRepresentation

        }

        return variableName + "." + methodName + "(" + argumentsList + ")"

    }

}
