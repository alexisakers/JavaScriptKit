//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation
import WebKit

/**
 * A JavaScript expression that can be evaluated inside of a web view (`WKWebView`).
 *
 * The library provides ready-to-use expression implementations:
 * - `JSVariable` to access a variable
 * - `JSFunction` to call a function
 * - `JSScript` to run a custom script
 *
 * You don't need to implement this protocol yourself.
 *
 * Expressions are specialized with the `ReturnType` associated type. Expressions can return any
 * `Decodable` type. This includes:
 *
 * - `JSVoid` for expressions that do not return a value
 * - Primitive values (Strings, Numbers, Booleans, ...)
 * - Decodable enumerations
 * - Objects decodable from JSON
 * - Arrays of primitive values
 * - Arrays of enumeration cases
 * - Arrays of objects
 * - Native dictionaries
 */

public protocol JSExpression {

    /// The expected return type of the expression.
    associatedtype ReturnType: Decodable

    /**
     * The decoding strategy to use to evaluate the validity of the result.
     * - note: The default implementation always returns `returnValueMandatory`, except for `JSVoid`.
     */

    /// The decoding strategy to use to evaluate the validity of the result.
    var decodingStrategy: JSDecodingStrategy<ReturnType> { get }

    /// Creates the JavaScript text of the expression.
    func makeExpressionString() throws -> String

}

// MARK: - Supporting Types

/**
 * The strategies to decode a value.
 *
 * Strategies are used to determine whether the evaluation result sent by the web view is valid or not.
 */

public enum JSDecodingStrategy<ReturnType> {

    /**
     * A return value is mandatory.
     *
     * If a value or an error is not provided, the result of the expression will be considered
     * invalid.
     */

    case returnValueMandatory

    /**
     * The expression must not return a value.
     *
     * If a value is provided, the result of the expression will be considered invalid.
     *
     * When no value and no error is provided, the default value will be passed to your completion
     * handler.
     *
     * This strategy must only be used when `ReturnType` is `JSVoid`, as the web view will not
     * provide a value on success for this return type.
     *
     * - parameter defaultValue: The default value. Should be a `JSVoid` value, i.e. `JSVoid()`.
     */

    case noReturnValue(defaultValue: ReturnType)

    /// Indicates whether the expression must return a value.
    var expectsReturnValue: Bool {
        switch self {
        case .returnValueMandatory: return true
        case .noReturnValue(_): return false
        }
    }

}

// MARK: - Helpers

extension JSExpression {

    /// The result type of the expression.
    public typealias EvaluationResult = Result<ReturnType, JSErrorDomain>

    /**
     * The type of block to execute with the execution result.
     * - parameter result: The result of the evaluation. Will be `.success(ReturnType)` if a valid
     * return value was parsed ; or `.error(JSErrorDomain)` if an error was thrown by the web view
     * when evaluating the script.
     */

    public typealias EvaluationCallback = (_ result: EvaluationResult) -> Void

    /// The decoding strategy to use to evaluate the validity of the result.
    public var decodingStrategy: JSDecodingStrategy<ReturnType> {
        if ReturnType.self == JSVoid.self {
            return .noReturnValue(defaultValue: JSVoid() as! ReturnType)
        }

        return .returnValueMandatory
    }

}
