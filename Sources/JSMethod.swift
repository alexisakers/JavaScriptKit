import Foundation

///
/// Représente une méthode qui appartient à une variable.
///
/// `ReturnType` représente le type de la valeur retournée par la fonction.
///

public class JSMethod<ReturnType>: JSExpression<ReturnType> {
    
    /// Le nom de la variable à laquelle la méthode appartient.
    public let variableName: String

    /// Le nom de la méthode.
    public let methodName: String

    /// Les arguments à passer lors de l'appel de la fonction.
    public let arguments: [JSConvertible]

    ///
    /// Créé une référence vers une méthode d'une variable.
    ///
    /// - parameter objectName: Le nom de l'objet global auquel la méthode appartient.
    /// - parameter methodName: Le nom de la méthode.
    /// - parameter arguments: Les arguments à passer lors de l'appel de la fonction.
    ///

    public init(variableName: String, _ methodName: String, _ arguments: JSConvertible...) {
        self.variableName = variableName
        self.methodName = methodName
        self.arguments = arguments
    }

    public override var javaScriptString: String {

        let argumentsList = arguments.reduce("") {
            partialResult, argument in

            let separator = partialResult.isEmpty ? "" : ", "
            return partialResult + separator + argument.jsRepresentation

        }

        return variableName + "." + methodName + "(" + argumentsList + ")"

    }

}
