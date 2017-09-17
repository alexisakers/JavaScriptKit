/**
 *  JavaScriptKit
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
/// You don't need to implement this protocol yourself.
///
/// Expressions are specialized with the `ReturnType` associated type. Expressions can return any
/// `Decodable` type. This includes:
///
/// - `JSVoid` for expressions that do not return a value
/// - Primitive values (Strings, Numbers, Booleans, ...)
/// - Decodable enumerations
/// - Objects decodable from JSON
/// - Arrays of primitive values
/// - Arrays of enumeration cases
/// - Arrays of objects
/// - Native dictionaries
///

public protocol JSExpression {

    /// The expected return type of the expression.
    associatedtype ReturnType: Decodable

    /// Creates the JavaScript text of the expression.
    func makeExpressionString() throws -> String

}


// MARK: - Supporting Types

///
/// The strategies to decode a value.
///
/// Strategies are used to determine whether the evaluation result sent by the web view is valid or not.
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
    /// When no value and no error is provided, the default value will be passed to your completion
    /// handler.
    ///
    /// This strategy must only be used when `ReturnType` is `JSVoid`, as the web view will not
    /// provide a value on success for this return type.
    ///
    /// - parameter defaultValue: The default value. Should be a `JSVoid` value, i.e. `JSVoid()`.
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

    /// The decoding strategy to use to evaluate the validity of the result.
    private var decodingStrategy: JSDecodingStrategy<ReturnType> {

        if ReturnType.self == JSVoid.self {
            return .noReturnValue(defaultValue: JSVoid() as! ReturnType)
        } else {
            return .returnValueMandatory
        }

    }

    ///
    /// Evaluates the expression inside of a web view's JavaScript context.
    ///
    /// - parameter webView: The web view to execute the code in.
    /// - parameter completionHandler: The code to execute with the execution result.
    /// - parameter result: The result of the evaluation. Will be `.success(ReturnType)` if a valid
    /// return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web view
    /// when evaluating the script.
    ///
    /// - note: The completion handler always runs on the main thread.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: ((_ result: Result<ReturnType, JSErrorDomain>) -> Void)?) {

        DispatchQueue.global(qos: .userInitiated).async {

            do {
                let expressionString = try self.makeExpressionString()
                let evaluationWorkItem = self.performEvaluation(expressionString, webView: webView, completionHandler: completionHandler)
                DispatchQueue.main.async(execute: evaluationWorkItem)
            } catch {
                let nsError = error as NSError
                self.completeEvaluation(completionHandler, .failure(.invalidExpression(nsError)))
            }

        }


    }

    ///
    /// Evaluates the expression on the main thread and parses the result on a background queue.
    ///
    /// - parameter expressionString: The JavaScript expression to execute.
    /// - parameter webView: The web view where to execute the expression.
    /// - parameter completionHandler: The code to execute with the parsed execution results.
    ///

    private func performEvaluation(_ expressionString: String,
                                   webView: WKWebView,
                                   completionHandler: ((_ result: Result<ReturnType, JSErrorDomain>) -> Void)?) -> DispatchWorkItem {

        return DispatchWorkItem {

            webView.evaluateJavaScript(expressionString) {
                value, error in
                DispatchQueue.global(qos: .userInitiated).async {
                    self.handleEvaluationCompletion(value, error, completionHandler)
                }
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
                                            _ completionHandler: ((_ result: Result<ReturnType, JSErrorDomain>) -> Void)?) {

        let decoder = JavaScriptDecoder()

        switch (resultValue, resultError) {

        case (let value?, nil):

            guard decodingStrategy.expectsReturnValue else {
                let typeError = JSErrorDomain.invalidReturnType(value: value)
                completeEvaluation(completionHandler, .failure(typeError))
                return
            }

            guard let decodedValue: ReturnType = try? decoder.decode(value) else {
                let typeError = JSErrorDomain.invalidReturnType(value: value)
                completeEvaluation(completionHandler, .failure(typeError))
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
