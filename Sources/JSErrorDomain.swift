/**
 *  JavaScriptKit
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// JavaScript execution errors.
///

public enum JSErrorDomain {

    /// The script returned an incompatible value.
    case invalidReturnType(value: Any)

    /// The script was stopped because of an error.
    case executionError(NSError)

    /// The script returned an unexpected result.
    case unexpectedResult

    /// The expression could not be built because it is invalid.
    case invalidExpression(NSError)

}


// MARK: - ErrorDomain

extension JSErrorDomain: LocalizedError {

    public static var identifier = "fr.alexaubry.JavaScriptKit.JSErrorDomain"

    public var code: Int {

        switch self {
        case .invalidReturnType(_):
            return 2000
        case .executionError(_):
            return 2001
        case .unexpectedResult:
            return 2002
        case .invalidExpression(_):
            return 2003
        }

    }

    public var localizedDescription: String {

        switch self {
        case .invalidReturnType(_):
            return LocalizedStrings.invalidReturnType.localizedValue

        case .executionError(_):
            return LocalizedStrings.executionError.localizedValue

        case .unexpectedResult:
            return LocalizedStrings.unexpectedResult.localizedValue

        case .invalidExpression(_):
            return LocalizedStrings.invalidExpression.localizedValue
        }

    }

    public var underlyingError: NSError? {

        switch self {
        case .executionError(let error), .invalidExpression(let error):
            return error
        default:
            return nil
        }

    }

    /// Creates an NSError describing the receiver.
    public var nsError: NSError {

        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = localizedDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError

        return NSError(domain: JSErrorDomain.identifier,
                       code: code,
                       userInfo: userInfo)

    }

    public var errorDescription: String {
        return localizedDescription
    }

}


// MARK: - Localization

extension JSErrorDomain {

    private enum LocalizedStrings: String {

        static var localizationContainer = Bundle(identifier: "fr.alexaubry.JavaScriptKit")!
        static var localizationTableName = "Localizable"

        case invalidReturnType = "JSErrorDomain.InvalidReturnType"
        case executionError = "JSErrorDomain.ExecutionError"
        case unexpectedResult = "JSErrorDomain.UnexpectedResult"
        case invalidExpression = "JSErrorDomain.InvalidExpression"

        var localizedValue: String {

            return NSLocalizedString(rawValue,
                                     tableName: LocalizedStrings.localizationTableName,
                                     bundle: LocalizedStrings.localizationContainer,
                                     value: "",
                                     comment: "")

        }

    }

}
