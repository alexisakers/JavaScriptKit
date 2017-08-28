import Foundation

///
/// Représente une propriété qui appartient à une variable.
///
/// `ReturnType` représente le type de la propriété.
///

public class JSProperty<ReturnType>: JSExpression<ReturnType> {

    /// Le nom de la variable auquel la propriété appartient.
    public let variableName: String

    /// Le nom de la propriété.
    public let propertyName: String

    ///
    /// Créé une référence vers une propriété d'une variable.
    ///
    /// - parameter variableName: Le nom de la variable auquel la propriété appartient.
    /// - parameter methodName: Le nom de la propriété.
    ///

    public init(variableName: String, _ propertyName: String) {
        self.variableName = variableName
        self.propertyName = propertyName
    }

    override var javaScriptString: String {
        return variableName + "." + propertyName
    }

}
