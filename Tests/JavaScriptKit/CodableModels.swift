import Foundation
import JavaScriptKit

// MARK: Empty Object

/// An object that does not encode a value.
class EmptyObject: Encodable {

    class Void: Encodable {
        func encode(to encoder: Encoder) {}
    }

    let void = Void()

    func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(void)
    }

}

// MARK: - User

/// A simple structure
struct User: Encodable {
    let displayName: String
    let handle: String
}

// MARK: - Person

/// A structure with nested unkeyed containers containing keyed containers.
struct Person: Encodable {
    let firstName: String
    let lastName: String
    let birthDate: Date
    let mainAddress: Address
    let socialMediaURL: URL
    var bestFriends: [Person]?
}

// MARK: - Address

/// A structure with an optional field.
struct Address: Encodable {
    let line1: String
    let line2: String?
    let zipCode: Int
    let city: String
    let country: Country
}

// MARK: - Country

/// A Raw Representable and Codable enum.
enum Country: String, Encodable {
    case discoveryland = "DISCOVERYLAND"
    case utopia = "UTOPIA"
}
