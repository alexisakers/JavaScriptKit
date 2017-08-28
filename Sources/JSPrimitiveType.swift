import Foundation
import CoreGraphics

// MARK: - Convertible

///
/// Un type qui peut être converti en JavaScript.
///

public protocol JSConvertible {
    var jsRepresentation: String { get }
}

extension RawRepresentable where RawValue: JSConvertible {

    var jsRepresentation: String {
        return rawValue.jsRepresentation
    }

}

// MARK: Primitive Types

///
/// Un type qui peut être représenté en JavaScript.
///
/// - warning: Ce protocole est un détail d'implémentation du bridge web. Vous ne devez pas
/// ajouter de nouvelles conformances.
///

public protocol JSPrimitiveType: JSConvertible {}

extension JSPrimitiveType {
    public var jsRepresentation: String {
        return "\(self)"
    }
}

extension String: JSPrimitiveType {
    public var jsRepresentation: String {
        return "\"\(self)\""
    }
}

extension NSNumber: JSPrimitiveType {}
extension Int8: JSPrimitiveType {}
extension Double: JSPrimitiveType {}
extension Float: JSPrimitiveType {}
extension Int32: JSPrimitiveType {}
extension Int: JSPrimitiveType {}
extension Int64: JSPrimitiveType {}
extension Int16: JSPrimitiveType {}
extension UInt8: JSPrimitiveType {}
extension UInt32: JSPrimitiveType {}
extension UInt: JSPrimitiveType {}
extension UInt64: JSPrimitiveType {}
extension UInt16: JSPrimitiveType {}
extension CGFloat: JSPrimitiveType {}

extension Bool: JSPrimitiveType {}

// MARK: - Object

public protocol JSObject {
    init?(dictionary: NSDictionary)
}


// MARK: - Arrays

public protocol SequenceInitializableCollection: MutableCollection {
    init<S>(_ elements: S) where S : Sequence, Element == S.Element
}

extension Array: SequenceInitializableCollection {}

