//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation

/**
 * JavaScript execution errors.
 */

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

// MARK: - LocalizedError

extension JSErrorDomain: LocalizedError {

    /// The identifier of the error domain.
    public static var identifier = "fr.alexaubry.JavaScriptKit.JSErrorDomain"

    /// The localized description of the error.
    public var localizedDescription: String {
        switch self {
        case .invalidReturnType:
            return LocalizedStrings.invalidReturnType.localizedValue

        case .executionError:
            return LocalizedStrings.executionError.localizedValue

        case .unexpectedResult:
            return LocalizedStrings.unexpectedResult.localizedValue

        case .invalidExpression:
            return LocalizedStrings.invalidExpression.localizedValue
        }
    }

    /// The error that caused this error to be thrown.
    public var underlyingError: NSError? {
        switch self {
        case .executionError(let error), .invalidExpression(let error):
            return error
        default:
            return nil
        }
    }

    /// The localized description of the error.
    public var errorDescription: String? {
        return localizedDescription
    }

}

// MARK: - Bridging

extension JSErrorDomain: CustomNSError {

    public static var errorDomain: String {
        return JSErrorDomain.identifier
    }

    public var errorCode: Int {
        switch self {
        case .invalidReturnType:
            return 2000
        case .executionError:
            return 2001
        case .unexpectedResult:
            return 2002
        case .invalidExpression:
            return 2003
        }
    }

    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: localizedDescription,
        ]

        userInfo[NSUnderlyingErrorKey] = underlyingError
        return userInfo
    }

}

// MARK: - Localization

extension JSErrorDomain {

    /// A set of localized error strings.
    private enum LocalizedStrings: String {

        static let localizationTableName = "Localizable"

        static let localizationContainer: Bundle = {
            if let bundle = Bundle(identifier: "fr.alexaubry.JavaScriptKit") {
                return bundle
            } else {
                let frameworkBundle = Bundle(for: JavaScriptEncoder.self)
                let url = frameworkBundle.url(forResource: "JavaScriptKit", withExtension: "bundle")!
                return Bundle(url: url)!
            }
        }()

        case invalidReturnType = "JSErrorDomain.InvalidReturnType"
        case executionError = "JSErrorDomain.ExecutionError"
        case unexpectedResult = "JSErrorDomain.UnexpectedResult"
        case invalidExpression = "JSErrorDomain.InvalidExpression"

        /// The localized error description.
        var localizedValue: String {
            return NSLocalizedString(rawValue, tableName: LocalizedStrings.localizationTableName, bundle: LocalizedStrings.localizationContainer, value: "", comment: "")
        }

    }

}
