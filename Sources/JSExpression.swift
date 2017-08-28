import Foundation
import WebKit
import Result

///
/// Une expression qui peut être éxécutée dans un contexte JavaScript.
///
/// Cette classe est une classe abstraite que vous devez sous-classer.
/// Dans vos sous-classes, override la propriété `javaScriptString` pour
/// retourner le script correct.
///

public class JSExpression<ReturnType> {

    ///
    /// Le décodeur à utiliser pour parser le contenu JavaScript dans
    /// les réponses.
    ///

    public typealias Decoder = (_ value: Any) -> ReturnType?

    ///
    /// Le texte de l'expression.
    ///
    /// Cette propriété doit être overridée pour retourner le code JS
    /// à éxécuter.
    ///

    var javaScriptString: String {
        unavailable()
    }

}


// MARK: - Evaluation

extension JSExpression {

    ///
    /// La stratégie pour gérer les résultats de l'expression.
    ///

    public enum ResultHandlingStrategy {

        /// Une valeur de retour est obligatoire.
        case returnValueMandatory

        /// Pas de valeur attendue. Une valeur par défaut peut être utilisée.
        case noReturnValue(ReturnType)

        /// Indique si la stratégie impose une valeur de retour.
        var expectsReturnValue: Bool {
            switch self {
            case .returnValueMandatory: return true
            case .noReturnValue(_): return false
            }
        }

    }

    ///
    /// Évalue l'expression dans la VM d'une web view WebKit.
    ///
    /// - parameter webView: La web view où éxécuter le code.
    /// - parameter decoder: Le décodeur à utiliser pour parser la réponse.
    /// - parameter handlingStrategy: La stratégie pour décoder les résultats. Par défaut : `returnValueMandatory`.
    /// - parameter completionHandler: Le code à éxécuter avec les résultats de la fonction.
    ///

    public func evaluate(in webView: WKWebView,
                         decoder: @escaping Decoder,
                         handlingStrategy: ResultHandlingStrategy = .returnValueMandatory,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        webView.evaluateJavaScript(javaScriptString) {

            switch ($0, $1) {

            case (let value?, nil):

                guard handlingStrategy.expectsReturnValue else {
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

                if case let ResultHandlingStrategy.noReturnValue(defaultValue) = handlingStrategy {
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

    internal func decodeValue(_ value: Any) -> ReturnType? {
        return nil
    }

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluate(in: webView,
                      decoder: decodeValue,
                      handlingStrategy: .noReturnValue(()),
                      completionHandler: completionHandler)

    }

}


// MARK: - JSPrimitiveType

extension JSExpression where ReturnType: JSPrimitiveType {

    internal func decodeValue(_ value: Any) -> ReturnType? {
        return value as? ReturnType
    }

    ///
    /// Évalue l'expression dans la VM d'une web view WebKit et retourne
    /// la valeur primitive.
    ///
    /// - parameter webView: La web view où éxécuter le code.
    /// - parameter completionHandler: Le code à éxécuter avec les résultats de la fonction.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluate(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}


// MARK: - RawRepresentable

extension JSExpression where ReturnType: RawRepresentable, ReturnType.RawValue: JSPrimitiveType {

    internal func decodeValue(_ value: Any) -> ReturnType? {

        guard let rawValue = value as? ReturnType.RawValue else {
            return nil
        }

        return ReturnType.init(rawValue: rawValue)

    }

    ///
    /// Évalue l'expression dans la VM d'une web view WebKit et retourne
    /// la valeur de l'énumération.
    ///
    /// - parameter webView: La web view où éxécuter le code.
    /// - parameter completionHandler: Le code à éxécuter avec les résultats de la fonction.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluate(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}


// MARK: - JSObject

extension JSExpression where ReturnType: JSObject {

    internal func decodeValue(_ value: Any) -> ReturnType? {

        guard let dictionary = value as? NSDictionary else {
            return nil
        }
        
        guard let object = ReturnType(dictionary: dictionary) else {
            return nil
        }

        return object

    }

    ///
    /// Évalue l'expression dans la VM d'une web view WebKit et retourne
    /// l'objet.
    ///
    /// - parameter webView: La web view où éxécuter le code.
    /// - parameter completionHandler: Le code à éxécuter avec les résultats de la fonction.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluate(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}

// MARK: - Array<JSPrimitiveType>

extension JSExpression where ReturnType: SequenceInitializableCollection, ReturnType.Element: JSPrimitiveType {

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
    /// Évalue l'expression dans la VM d'une web view WebKit et retourne
    /// une liste de valeurs primitives.
    ///
    /// - parameter webView: La web view où éxécuter le code.
    /// - parameter completionHandler: Le code à éxécuter avec les résultats de la fonction.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluate(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}


// MARK: - Array<RawRepresentable>

extension JSExpression where ReturnType: SequenceInitializableCollection, ReturnType.Element: RawRepresentable, ReturnType.Element.RawValue: JSPrimitiveType {

    internal func decodeValue(_ value: Any) -> ReturnType? {

        guard let typedValue = value as? NSArray else {
            return nil
        }

        let array: [ReturnType.Element]? = try? typedValue.map {

            guard let rawValue = $0 as? ReturnType.Element.RawValue else {
                throw JSErrorDomain.unexpectedResult
            }

            guard let element = ReturnType.Element.init(rawValue: rawValue) else {
                throw JSErrorDomain.unexpectedResult
            }

            return element

        }

        guard let decodedArray = array else {
            return nil
        }

        return ReturnType.init(decodedArray)

    }

    ///
    /// Évalue l'expression dans la VM d'une web view WebKit et retourne
    /// une liste de valeurs d'énumération.
    ///
    /// - parameter webView: La web view où éxécuter le code.
    /// - parameter completionHandler: Le code à éxécuter avec les résultats de la fonction.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluate(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}


// MARK: - Array<JSObject>

extension JSExpression where ReturnType: SequenceInitializableCollection, ReturnType.Element: JSObject {

    internal func decodeValue(_ value: Any) -> ReturnType? {

        guard let dictionaries = value as? NSArray else {
            return nil
        }

        let array: [ReturnType.Element]? = try? dictionaries.map {

            guard let dictionary = $0 as? NSDictionary else {
                throw JSErrorDomain.unexpectedResult
            }

            guard let element = ReturnType.Element(dictionary: dictionary) else {
                throw JSErrorDomain.unexpectedResult
            }

            return element

        }


        guard let decodedArray = array else {
            return nil
        }

        return ReturnType.init(decodedArray)

    }

    ///
    /// Évalue l'expression dans la VM d'une web view WebKit et retourne
    /// une liste d'objets.
    ///
    /// - parameter webView: La web view où éxécuter le code.
    /// - parameter completionHandler: Le code à éxécuter avec les résultats de la fonction.
    ///

    public func evaluate(in webView: WKWebView,
                         completionHandler: @escaping (Result<ReturnType, JSErrorDomain>) -> Void) {

        self.evaluate(in: webView, decoder: decodeValue, completionHandler: completionHandler)

    }

}
