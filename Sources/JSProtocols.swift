/**
 *  JSBridge
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation
import CoreGraphics

// MARK: Convertible types

///
/// A type whose values can be converted to a JavaScript textual representation.
///
/// You can make your custom types conform to it if they can be converted to JavaScript.
///
/// You can also use it to make your enumerations automatically compatible with the API
/// if their `RawValue` is `JSConvertible`:
///
/// ~~~swift
/// public enum FontFamily: String, JSConvertible {
///     case sanFrancisco
///     case arial
///     case times
/// }
/// ~~~
///
/// In this example, the raw value of `FontFamily` will now automatically be used
/// in any API requiring a `JSConvertible` value.
///

public protocol JSConvertible {

    /// The JavaScript textual representation of the value.
    var jsRepresentation: String { get }
}

extension RawRepresentable where RawValue: JSConvertible {

    var jsRepresentation: String {
        return rawValue.jsRepresentation
    }

}


// MARK: - Primitive Types

///
/// A type that is native to both Swift and JavaScript.
///
/// - warning: This protocol is an implementation detail of `JSBridge`. Do not
/// make your types conform to it.
///

public protocol JSPrimitiveType: JSConvertible {}

extension JSPrimitiveType {
    public var jsRepresentation: String {
        return "\(self)"
    }
}

extension String: JSPrimitiveType {
    public var jsRepresentation: String {
        return "\"\(self)\""
    }
}

extension Bool: JSPrimitiveType {}

extension Double: JSPrimitiveType {}
extension Float: JSPrimitiveType {}
extension CGFloat: JSPrimitiveType {}
extension NSNumber: JSPrimitiveType {}

extension Int: JSPrimitiveType {}
extension Int8: JSPrimitiveType {}
extension Int16: JSPrimitiveType {}
extension Int32: JSPrimitiveType {}
extension Int64: JSPrimitiveType {}

extension UInt: JSPrimitiveType {}
extension UInt8: JSPrimitiveType {}
extension UInt16: JSPrimitiveType {}
extension UInt32: JSPrimitiveType {}
extension UInt64: JSPrimitiveType {}

extension Date: JSPrimitiveType {

    public var jsRepresentation: String {
        return "new Date(\(timeIntervalSince1970 * 1000))"
    }

}

// MARK: - Object

///
/// A compound object that can be created from a JS object literal.
///

public protocol JSObject {

    ///
    /// Creates the Swift object from a JavaScript object literal.
    ///
    /// Implement this initializer to configure your object with the contents
    /// of its JS counterpart. You can return `nil` if the object literal is
    /// not compatible with your model.
    ///
    /// - parameter objectLiteral: The JavaScript body of the object.
    /// - returns: The initialized object, or `nil` if `objectLiteral` is not
    /// compatible with the type's model.
    ///

    init?(objectLiteral: NSDictionary)

}


// MARK: - Arrays

///
/// A mutable collection than can be initialized from a Sequence.
///

public protocol SequenceInitializableCollection: MutableCollection {

    ///
    /// Creates a mutable collection from the elements of a sequence.
    ///
    /// - parameter elements: The sequence of elements to copy to a new mutable
    /// collection.
    ///

    init<S>(_ elements: S) where S : Sequence, Element == S.Element
}

extension Array: SequenceInitializableCollection {}
