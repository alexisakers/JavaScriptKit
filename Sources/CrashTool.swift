import Foundation

///
/// Une classe pour utiliser des `fatalError` personnalisées.
///
/// Ne doit être utilisé que dans ce fichier et les tests.
///

class FatalErrorManager {

    /// Une erreur fatale.
    typealias FatalError = (@autoclosure () -> String, StaticString, UInt) -> Any

    /// La fonction de gestion des erreurs fatales.
    static var fatalErrorClosure = FatalErrorManager.defaultFatalErrorClosure

    /// La fonction de gestion des erreurs fatales par défaut.
    private static let defaultFatalErrorClosure: FatalError = Swift.fatalError

    /// Remplace la fonction de gestion des erreurs fatales par une fonction de test.
    static func replaceFatalError(closure: @escaping FatalError) {
        fatalErrorClosure = closure
    }

    /// Rétablit la fonction de gestion des erreurs fatales par défaut.
    static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }

}

/// Arrête l'éxécution du programme.
public func stop() -> Never {
    while true {
        RunLoop.current.run()
    }
}

/// Arrête le programme avec un message d'erreur.
public func fail(_ message: @autoclosure () -> String, _ file: StaticString = #file, _ line: UInt = #line) -> Never {
    _ = FatalErrorManager.fatalErrorClosure(message(), file, line)
    stop()
}

/// Arrête le programme lorsqu'une fonction n'est pas disponible.
public func unavailable(_ function: String = #function, _ file: String = #file, _ line: Int = #line) -> Never {
    let message = "\(file):\(line) — \(function) is not available."
    fail(message)
}
