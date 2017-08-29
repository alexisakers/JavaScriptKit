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
/// The library provides ready-to-use expression implementations:
/// - `JSVariable` to access a variable
/// - `JSFunction` to call a function
/// - `JSScript` to run a custom script
///
/// To implement this protocol, you first need to determine the return type of the expression. You
/// must choose one of the compatible types:
/// - `Void`
/// - Primitive value (`JSPrimitiveType`)
/// - Enum case with a primitive `RawValue`
/// - Object (`JSObject`)
/// - Array of primitive values
/// - Array of enum cases with a primitive `RawValue`
/// - Array of objects.
///
/// Use the chosen return type as the `ReturnType` associated type.
///
/// Then, implement the `makeExpressionString` method, that must return the text of the expression
/// to evaluate.
///

public protocol JSExpression {

    /// The expected return type of the expression.
    associatedtype ReturnType

    /// Creates the JavaScript text of the expression.
    func makeExpressionString() -> String

}


// MARK: - Supporting Types

///
/// The strategies to decode a value.
///
/// Strategies are used when the web view sends the result of the expression to determine
/// whether it is valid or not.
///
/// Usually, you don't need to specify a strategy, as the correct one is automatically selected
/// for compatible return types.
///

public enum JSDecodingStrategy<ReturnType> {

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


// MARK: - Evaluation

extension JSExpression {

    ///
    /// Evaluates the expression inside of a web view's JavaScript context.
    ///
    /// You should not use this function directly. Instead, use `evaluate(in:,completionHandler:)`
    /// which is available when the return type is compatible with JavaScript.
    ///
    /// - note: The completion handler always runs on the main thread.
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
    /// - parameter decoder: A function that can decode a value passed by the web view's JavaScript
    /// context to the expected return type of the expression. Returns the decoded value, or `nil`
    /// if `value` is not compatible with `ReturnType`.
    /// - parameter value: The value returned by the JavaScript context.
    /// - parameter decodingStrategy: The decoding strategy to use to evaluate the validity of the
    /// result. Defaults to `returnValueMandatory`.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    /// - parameter result:  The result of the evaluation. Will be `.success(ReturnType)` if a valid
    /// return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web view
    /// when evaluating the script.
    ///

    public func evaluateScript(in webView: WKWebView,
                               decoder: @escaping (_ value: Any) -> ReturnType?,
                               decodingStrategy: JSDecodingStrategy<ReturnType> = .returnValueMandatory,
                               completionHandler: ((_ result: Result<ReturnType, JSErrorDomain>) -> Void)?) {

        let expressionString = self.makeExpressionString()

        webView.evaluateJavaScript(expressionString) {
            value, error in
            DispatchQueue.global(qos: .userInitiated).async {
                self.handleEvaluationCompletion(value, error, decoder, decodingStrategy, completionHandler)
            }
        }

    }

    ///
    /// Handles the evaluation result of the expression sent by a web view. This must be called from
    /// the compeltion handler provided by the web view inside an async background block.
    ///
    /// - parameter resultValue: The expression return value.
    /// - parameter resultError: The evaluation error.
    /// - parameter decoder: The function to decode the `resultValue`.
    /// - parameter decodingStrategy: The strategy to follow when decoding the result.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///

    private func handleEvaluationCompletion(_ resultValue: Any?,
                                            _ resultError: Error?,
                                            _ decoder: @escaping (_ value: Any) -> ReturnType?,
                                            _ decodingStrategy: JSDecodingStrategy<ReturnType>,
                                            _ completionHandler: ((_ result: Result<ReturnType, JSErrorDomain>) -> Void)?) {

        switch (resultValue, resultError) {

        case (let value?, nil):

            guard decodingStrategy.expectsReturnValue else {
                let typeError = JSErrorDomain.invalidReturnType(value: value)
                completionHandler?(.failure(typeError))
                return
            }

            guard let decodedValue = decoder(value) else {
                let typeError = JSErrorDomain.invalidReturnType(value: value)
                completionHandler?(.failure(typeError))
                return
            }

            completeEvaluation(completionHandler, .success(decodedValue))

        case (nil, let error?):
            let executionError = JSErrorDomain.executionError(error as NSError)
            completeEvaluation(completionHandler, .failure(executionError))

        default:

            if case let JSDecodingStrategy.noReturnValue(defaultValue) = decodingStrategy {
                completeEvaluation(completionHandler, .success(defaultValue))
                return
            }

            let unexpectedError = JSErrorDomain.unexpectedResult
            completeEvaluation(completionHandler, .failure(unexpectedError))

        }

    }

    ///
    /// Executes a completion handler with the evaluation result on the main thread.
    ///
    /// - parameter completionHandler: The code to execute with the results.
    /// - parameter  result: The evaluation result.
    ///

    private func completeEvaluation(_ completionHandler: ((_ result: Result<ReturnType, JSErrorDomain>) -> Void)?,
                                    _ result: Result<ReturnType, JSErrorDomain>) {

        DispatchQueue.main.async {
            completionHandler?(result)
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
    /// - note: The completion handler always runs on the main thread.
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
    /// - note: The completion handler always runs on the main thread.
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
    /// - note: The completion handler always runs on the main thread.
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
    /// - note: The completion handler always runs on the main thread.
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
    /// - note: The completion handler always runs on the main thread.
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
    /// - note: The completion handler always runs on the main thread.
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
    /// - note: The completion handler always runs on the main thread.
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
