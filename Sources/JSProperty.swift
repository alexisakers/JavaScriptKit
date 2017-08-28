/**
 *  JSBridge
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// A concrete JavaScript expression that returns the value of a property
/// that belongs to a variable of the current JavaScript `this`.
///
/// For instance, to get the title of the current document:
///
/// ~~~swift
/// let title = JSProperty<String>("document", "title")
/// // equivalent to the JS script `this.document.title;`
/// ~~~
///
/// Instances of this class are specialized with the `ReturnType` generic parameter.
/// It must be set to the type of the JavaScript property to query. Check the docs of
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

public class JSProperty<ReturnType>: JSExpression<ReturnType> {

    ///
    /// The name of the variable that contains the requested property.
    ///
    /// It must be a member of the current JavaScript `this`.
    ///

    public let variableName: String

    /// The name of the property to fetch.
    public let propertyName: String

    ///
    /// Creates a new JavaScript property description.
    ///
    /// - parameter variableName: The name of the variable that contains the requested property.
    /// - parameter methodName: The name of the property to fetch.
    ///

    public init(_ variableName: String, _ propertyName: String) {
        self.variableName = variableName
        self.propertyName = propertyName
    }

    override var javaScriptString: String {
        return variableName + "." + propertyName
    }

}
