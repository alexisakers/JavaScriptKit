//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation
import WebKit

extension WKWebView {

    /**
     * Evaluates a JavaScript expression inside of the web view's JavaScript context.
     *
     * - parameter expression: The expression to execute.
     * - parameter completionHandler: The code to execute with the execution result.
     *
     * - note: The completion handler always runs on the main thread.
     */

    public func evaluate<T: JSExpression>(expression: T, completionHandler: T.EvaluationCallback?) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let expressionString = try expression.makeExpressionString()
                let evaluationWorkItem = self.performEvaluation(for: expression, js: expressionString, completionHandler: completionHandler)
                DispatchQueue.main.async(execute: evaluationWorkItem)
            } catch {
                let nsError = error as NSError
                self.completeEvaluation(for: expression, completionHandler, .failure(.invalidExpression(nsError)))
            }
        }
    }

    /**
     * Evaluates the expression on the main thread and parses the result on a background queue.
     * - parameter expression: The expression that needs to be executed.
     * - parameter expressionString: The JavaScript expression to execute.
     * - parameter completionHandler: The code to execute with the parsed execution results.
     */

    private func performEvaluation<T: JSExpression>(for expression: T, js expressionString: String, completionHandler: T.EvaluationCallback?) -> DispatchWorkItem {
        return DispatchWorkItem {
            self.evaluateJavaScript(expressionString) {
                value, error in
                DispatchQueue.global(qos: .userInitiated).async {
                    self.handleEvaluationCompletion(for: expression, value, error, completionHandler)
                }
            }
        }
    }

    /**
     * Handles the evaluation result of the expression sent by a web view. This must be called from
     * the compeltion handler provided by the web view inside an async background block.
     *
     * - parameter expression: The expression that was evaluated.
     * - parameter resultValue: The expression return value.
     * - parameter resultError: The evaluation error.
     * - parameter decoder: The function to decode the `resultValue`.
     * - parameter decodingStrategy: The strategy to follow when decoding the result.
     * - parameter completionHandler: The code to execute with the parsed execution results.
     */

    private func handleEvaluationCompletion<T: JSExpression>(for expression: T, _ resultValue: Any?, _ resultError: Error?,
                                                             _ completionHandler: T.EvaluationCallback?) {
        let decoder = JavaScriptDecoder()

        switch (resultValue, resultError) {
        case (let value?, nil):
            // If there is a value but we don't expect one, fail.
            guard expression.decodingStrategy.expectsReturnValue else {
                let typeError = JSErrorDomain.invalidReturnType(value: value)
                completeEvaluation(for: expression, completionHandler, .failure(typeError))
                return
            }

            // Try to decode the value.
            guard let decodedValue: T.ReturnType = try? decoder.decode(value) else {
                let typeError = JSErrorDomain.invalidReturnType(value: value)
                completeEvaluation(for: expression, completionHandler, .failure(typeError))
                return
            }

            // Pass the decoded value.
            completeEvaluation(for: expression, completionHandler, .success(decodedValue))

        case (nil, let error?):
            // Pass any execution errors.
            let executionError = JSErrorDomain.executionError(error as NSError)
            completeEvaluation(for: expression, completionHandler, .failure(executionError))

        default:
            // If there is no value but we don't expect one, return the default value.
            if case let JSDecodingStrategy.noReturnValue(defaultValue) = expression.decodingStrategy {
                completeEvaluation(for: expression, completionHandler, .success(defaultValue))
                return
            }

            // Unexpected result otherwise.
            let unexpectedError = JSErrorDomain.unexpectedResult
            completeEvaluation(for: expression, completionHandler, .failure(unexpectedError))
        }
    }

    /**
     * Executes a completion handler with the evaluation result on the main thread.
     *
     * - parameter expression: The expression that finished evaluating.
     * - parameter completionHandler: The code to execute with the results.
     * - parameter  result: The evaluation result.
     */

    private func completeEvaluation<T: JSExpression>(for expression: T, _ completionHandler: T.EvaluationCallback?, _ result: T.EvaluationResult) {
        DispatchQueue.main.async {
            completionHandler?(result)
        }
    }

}
