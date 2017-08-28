import Foundation

///
/// Les erreurs liées à l'éxécution JavaScript.
///

public enum JSErrorDomain {

    /// Le script a retourné une valeur incompatible.
    case invalidReturnType(value: Any)

    /// L'éxécution du script a été interrompue en raison d'une erreur.
    case executionError(NSError)

    /// Le script a retourné un résultat inattendu.
    case unexpectedResult

}


// MARK: - ErrorDomain

extension JSErrorDomain: ErrorDomain {

    public static var identifier = "com.iphonconcept.AppFoundation.JSErrorDomain"

    public var code: Int {

        switch self {
        case .invalidReturnType(_):
            return 2000
        case .executionError(_):
            return 2001
        case .unexpectedResult:
            return 2002
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
        }

    }

    public var underlyingError: NSError? {

        switch self {
        case .executionError(let error):
            return error
        default:
            return nil
        }

    }

}


// MARK: - Localization

extension JSErrorDomain {

    private enum LocalizedStrings: String, Localizable {

        static var localizationContainer = Bundle(identifier: "fr.aura-media.JSBridge")!
        static var localizationTableName = "Error"

        case invalidReturnType = "JSErrorDomain.InvalidReturnType"
        case executionError = "JSErrorDomain.ExecutionError"
        case unexpectedResult = "JSErrorDomain.UnexpectedResult"

    }

}
