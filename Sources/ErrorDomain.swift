import Foundation

///
/// Un domaine d'erreur.
///

public protocol ErrorDomain: LocalizedError {

    /// L'identifiant du domaine.
    static var identifier: String { get }

    /// Le code de l'erreur.
    var code: Int { get }

    /// La description de l'erreur.
    var localizedDescription: String { get }

    /// (Optionnel) L'erreur qui a provoqué cette erreur.
    var underlyingError: NSError? { get }

}

extension ErrorDomain {

    /// Convertit l'erreur au format NSError.
    public var nsError: NSError {

        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = localizedDescription
        userInfo[NSUnderlyingErrorKey] = underlyingError

        return NSError(domain: Self.identifier,
                       code: code,
                       userInfo: userInfo)

    }

    public var errorDescription: String {
        return localizedDescription
    }

}
