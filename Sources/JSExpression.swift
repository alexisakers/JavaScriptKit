/**
 *  JSBridge
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation
import WebKit
import Result

///
/// A JavaScript expression that can be evaluated inside of a web view (`WKWebView`).
///
/// Instances of this class are specialized with the `ReturnType` parameter that specifies the
/// expected return type of the expression.
///
/// This class is an abstract superclass that you need to subclass. In your concrete subclasses,
/// override the `javaScriptString` property to return an appropriate script string.
///
/// The library provides ready-to-use subclasses:
/// - `JSGlobal` to access a global variable
/// - `JSProperty` to access a property of a global variable
/// - `JSFreeFunction` to call a global function
/// - `JSMethod` to call a method of a global variable
///

public class JSExpression<ReturnType> {

    ///
    /// A function that can decode a value passed by the web view's JavaScript context to the
    /// expected return type of the expression.
    ///
    /// Usually, you do not need to create your own decoder, as default ones are implemented for
    /// compatible return types.
    ///
    /// - parameter value: The value returned by the JavaScript context.
    /// - returns: The decoded value, or `nil` if `value` is not compatible with `ReturnType`.
    ///

    public typealias Decoder = (_ value: Any) -> ReturnType?

    ///
    /// The strategies to decode a value.
    ///
    /// Strategies are used when the web view sends the result of the expression to determine
    /// whether it is valid or not.
    ///
    /// Usually, you don't need to specify a strategy, as the correct one is automatically selected
    /// for compatible return types.
    ///

    public enum DecodingStrategy {

        ///
        /// A return value is mandatory.
        ///
        /// If a value or an error is not provided, the result of the expression will be considered
        /// invalid.
        ///

        case returnValueMandatory

        ///
        /// The expression must not return a value.
        ///
        /// If a value is provided, the result of the expression will be considered invalid.
        ///
        /// When no value or error is provided, the default value will be passed to your completion
        /// handler.
        ///
        /// This strategy must only be used for `Void` return types, as the web view will not
        /// provide a value on success for this return type.
        ///
        /// - parameter defaultValue: The default value. Should be the `Void` literal, i.e.
        /// an empty tuple (`()`).
        ///

        case noReturnValue(defaultValue: ReturnType)

        /// Indicates whether the expression must return a value.
        var expectsReturnValue: Bool {
            switch self {
            case .returnValueMandatory: return true
            case .noReturnValue(_): return false
            }
        }

    }

    ///
    /// The JavaScript text of the expression.
    ///
    /// This property needs to be overriden and used by concrete subclasses. Failure to comply with
    /// this requirement causes your app to crash.
    ///

    var javaScriptString: String {
        unavailable()
    }

}


// MARK: - Evaluation

extension JSExpression {

    ///
    /// Evaluates the expression inside of a web view's JavaScript context.
    ///
    /// You should not use this function directly. Instead, use `evaluate(in:,completionHandler:)`
    /// which is available when the return type is compatible with JavaScript.
    ///
    /// Compatible types include:
    /// - `Void`
    /// - Primitive values (`JSPrimitiveType`)
    /// - Enum cases with a primitive `RawValue`
    /// - Objects (`JSObject`)
    /// - Arrays of primitive values
    /// - Arrays of enum cases with a primitive `RawValue`
    /// - Arrays of objects.
    ///
    /// - parameter webView: The web view to execute the code in.
    /// - parameter decoder: The decoder function to use to parse the evaluation response.
    /// - parameter decodingStrategy: The decoding strategy to use to evaluate the validity of the
    ///  result. Defaults to `returnValueMandatory`.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///     - result:  The result of the evaluation. Will be `.success(ReturnType)` if a valid
    ///     return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web
    ///     view when evaluating the script.
    ///

    public func evaluateScript(in webView: WKWebView,
                               decoder: @escaping Decoder,
                               decodingStrategy: DecodingStrategy = .returnValueMandatory,
                               completionHandler: @escaping (_ result: Result<ReturnType, JSErrorDomain>) -> Void) {

        webView.evaluateJavaScript(javaScriptString) {

            switch ($0, $1) {

            case (let value?, nil):

                guard decodingStrategy.expectsReturnValue else {
                    let typeError = JSErrorDomain.invalidReturnType(value: value)
                    completionHandler(.failure(typeError))
                    return
                }

                guard let decodedValue = decoder(value) else {
                    let typeError = JSErrorDomain.invalidReturnType(value: value)
                    completionHandler(.failure(typeError))
                    return
                }

                completionHandler(.success(decodedValue))

            case (nil, let error?):
                let executionError = JSErrorDomain.executionError(error as NSError)
                completionHandler(.failure(executionError))

            default:

                if case let DecodingStrategy.noReturnValue(defaultValue) = decodingStrategy {
                    completionHandler(.success(defaultValue))
                    return
                }

                let unexpectedError = JSErrorDomain.unexpectedResult
                completionHandler(.failure(unexpectedError))

            }

        }

    }

}


// MARK: - Void

extension JSExpression where ReturnType == Void {

    /// Decoder for a `Void` value.
    internal func decodeValue(_ value: Any) -> ReturnType? {
        return nil
    }

    ///
    /// Evaluates the expression inside of a web view's JavaScript context when the return value
    /// is `Void`.
    ///
    /// - parameter webView: The web view to execute the code in.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///     - result:  The result of the evaluation. Will be `.success(ReturnType)` if a valid
    ///     return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web
    ///     view when evaluating the script.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluateScript(in: webView,
                            decoder: decodeValue,
                            decodingStrategy: .noReturnValue(defaultValue: ()),
                            completionHandler: completionHandler)

    }

}


// MARK: - JSPrimitiveType

extension JSExpression where ReturnType: JSPrimitiveType {

    /// Decoder for primitive values.
    internal func decodeValue(_ value: Any) -> ReturnType? {
        return value as? ReturnType
    }


    ///
    /// Evaluates the expression inside of a web view's JavaScript context when the return value
    /// is a primitive type.
    ///
    /// - parameter webView: The web view to execute the code in.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///     - result:  The result of the evaluation. Will be `.success(ReturnType)` if a valid
    ///     return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web
    ///     view when evaluating the script.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluateScript(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}


// MARK: - RawRepresentable

extension JSExpression where ReturnType: RawRepresentable, ReturnType.RawValue: JSPrimitiveType {

    /// Decoder for primitive enum cases.
    internal func decodeValue(_ value: Any) -> ReturnType? {

        guard let rawValue = value as? ReturnType.RawValue else {
            return nil
        }

        return ReturnType(rawValue: rawValue)

    }


    ///
    /// Evaluates the expression inside of a web view's JavaScript context when the return value
    /// is a primitive enum case.
    ///
    /// - parameter webView: The web view to execute the code in.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///     - result:  The result of the evaluation. Will be `.success(ReturnType)` if a valid
    ///     return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web
    ///     view when evaluating the script.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluateScript(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}


// MARK: - JSObject

extension JSExpression where ReturnType: JSObject {

    /// Decoder for objets.
    internal func decodeValue(_ value: Any) -> ReturnType? {

        guard let dictionary = value as? NSDictionary else {
            return nil
        }
        
        guard let object = ReturnType(objectLiteral: dictionary) else {
            return nil
        }

        return object

    }


    ///
    /// Evaluates the expression inside of a web view's JavaScript context when the return value
    /// is an object.
    ///
    /// - parameter webView: The web view to execute the code in.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///     - result:  The result of the evaluation. Will be `.success(ReturnType)` if a valid
    ///     return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web
    ///     view when evaluating the script.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluateScript(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}

// MARK: - Array<JSPrimitiveType>

extension JSExpression where ReturnType: SequenceInitializableCollection, ReturnType.Element: JSPrimitiveType {

    /// Decoder for arrays with primitive values.
    internal func decodeValue(_ value: Any) -> ReturnType? {

        guard let typedValue = value as? NSArray else {
            return nil
        }

        let array: [ReturnType.Element]? = try? typedValue.map {

            guard let element = $0 as? ReturnType.Element else {
                throw JSErrorDomain.unexpectedResult
            }

            return element

        }

        guard let decodedArray = array else {
            return nil
        }

        return ReturnType(decodedArray)

    }

    ///
    /// Evaluates the expression inside of a web view's JavaScript context when the return value
    /// is an array of primitive values.
    ///
    /// - parameter webView: The web view to execute the code in.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///     - result:  The result of the evaluation. Will be `.success(ReturnType)` if a valid
    ///     return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web
    ///     view when evaluating the script.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluateScript(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}


// MARK: - Array<RawRepresentable>

extension JSExpression where ReturnType: SequenceInitializableCollection, ReturnType.Element: RawRepresentable, ReturnType.Element.RawValue: JSPrimitiveType {

    /// Decoder for arrays of primitive enum cases.
    internal func decodeValue(_ value: Any) -> ReturnType? {

        guard let typedValue = value as? NSArray else {
            return nil
        }

        let array: [ReturnType.Element]? = try? typedValue.map {

            guard let rawValue = $0 as? ReturnType.Element.RawValue else {
                throw JSErrorDomain.unexpectedResult
            }

            guard let element = ReturnType.Element(rawValue: rawValue) else {
                throw JSErrorDomain.unexpectedResult
            }

            return element

        }

        guard let decodedArray = array else {
            return nil
        }

        return ReturnType(decodedArray)

    }

    ///
    /// Evaluates the expression inside of a web view's JavaScript context when the return value
    /// is an array of primitive enum cases.
    ///
    /// - parameter webView: The web view to execute the code in.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///     - result:  The result of the evaluation. Will be `.success(ReturnType)` if a valid
    ///     return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web
    ///     view when evaluating the script.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluateScript(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}


// MARK: - Array<JSObject>

extension JSExpression where ReturnType: SequenceInitializableCollection, ReturnType.Element: JSObject {

    /// Decoder for arrays of objects.
    internal func decodeValue(_ value: Any) -> ReturnType? {

        guard let dictionaries = value as? NSArray else {
            return nil
        }

        let array: [ReturnType.Element]? = try? dictionaries.map {

            guard let dictionary = $0 as? NSDictionary else {
                throw JSErrorDomain.unexpectedResult
            }

            guard let element = ReturnType.Element(objectLiteral: dictionary) else {
                throw JSErrorDomain.unexpectedResult
            }

            return element

        }


        guard let decodedArray = array else {
            return nil
        }

        return ReturnType(decodedArray)

    }

    ///
    /// Evaluates the expression inside of a web view's JavaScript context when the return value
    /// is an array of objects.
    ///
    /// - parameter webView: The web view to execute the code in.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///     - result:  The result of the evaluation. Will be `.success(ReturnType)` if a valid
    ///     return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web
    ///     view when evaluating the script.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluateScript(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}
