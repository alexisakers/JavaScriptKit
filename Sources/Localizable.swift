import Foundation

///
/// Un type d'objets permettant d'accéder aux textes traduits.
///

public protocol Localizable: RawRepresentable where RawValue == String {

    /// Le nom du fichier de traduction.
    static var localizationTableName: String { get }

    /// Le paquet où se situe le fichier de localisation.
    static var localizationContainer: Bundle { get }

}

extension Localizable {

    /// Le texte traduit dans la langue actuelle.
    public var localizedValue: String {

        return NSLocalizedString(rawValue,
                                 tableName: Self.localizationTableName,
                                 bundle: Self.localizationContainer,
                                 value: "",
                                 comment: "")

    }

}
