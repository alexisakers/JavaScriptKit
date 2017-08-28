/**
 *  JSBridge
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// A concrete JavaScript expression that executes a global function of the current
/// JavaScript `this`.
///
/// For instance, to present an alert:
///
/// ~~~swift
/// let alert = JSFreeFunction<Void>("alert", "Hello from Swift!")
/// // equivalent to the JS script `this.alert("Hello from Swift!");`
/// ~~~
///
/// Instances of this class are specialized with the `ReturnType` generic parameter.
/// It must be set to the return type of the JavaScript function to execute. Check the docs of
/// the JavaScript function to know what to set the parameter to.
///
/// `ReturnType` must be a compatible type. Compatible types include:
/// - Primitive values (`JSPrimitiveType`)
/// - Enum cases with a primitive `RawValue`
/// - Objects (`JSObject`)
/// - Arrays of primitive values
/// - Arrays of enum cases with a primitive `RawValue`
/// - Arrays of objects.
///

public class JSFreeFunction<ReturnType>: JSExpression<ReturnType> {

    /// The name of the function to execute.
    public let functionName: String

    /// The arguments to pass to the functionName.
    public let arguments: [JSConvertible]

    ///
    /// Creates a new method description.
    ///
    /// - parameter functionName: The name of the method to execute.
    /// - parameter arguments: The arguments to pass to the method.
    ///

    public init(_ functionName: String, _ arguments: JSConvertible...) {
        self.functionName = functionName
        self.arguments = arguments
    }

    public override var javaScriptString: String {

        let argumentsList = arguments.reduce("") {
            partialResult, argument in

            let separator = partialResult.isEmpty ? "" : ", "
            return partialResult + separator + argument.jsRepresentation

        }

        return functionName + "(" + argumentsList + ")"

    }

}

