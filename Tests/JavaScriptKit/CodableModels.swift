import Foundation
import JavaScriptKit

// MARK: Empty Object

/// An object that does not encode a value.
class EmptyObject: Codable {

    class Void: Encodable {
        func encode(to encoder: Encoder) {}
    }

    let void = Void()

    func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(void)
    }

    init() {}
    required init(from decoder: Decoder) throws {}

}

// MARK: - User

/// A simple structure
struct User: Codable, Equatable {
    let displayName: String
    let handle: String

    static func == (lhs: User, rhs: User) -> Bool {
        return (lhs.displayName == rhs.displayName) && (lhs.handle == rhs.handle)
    }
}

// MARK: - Person

/// A structure with nested unkeyed containers containing keyed containers.
struct Company: Codable, Hashable {

    let name: String
    let address: Address
    var childCompanies: [Company]

    var hashValue: Int {
        return name.hashValue & address.hashValue & childCompanies.reduce(0) { $0 & $1.hashValue }
    }

    static func == (lhs: Company, rhs: Company) -> Bool {
        return (lhs.name == rhs.name) && (lhs.address == rhs.address) && (lhs.childCompanies == rhs.childCompanies)
    }

}

// MARK: - Address

/// A structure with an optional field.
struct Address: Codable, Hashable {

    let line1: String
    let line2: String?
    let zipCode: Int
    let city: String
    let country: Country

    var hashValue: Int {
        return line1.hashValue & (line2?.hashValue ?? 0) & zipCode & city.hashValue & country.hashValue
    }

    static func == (lhs: Address, rhs: Address) -> Bool {

        return (lhs.line1 == rhs.line1) &&
            (lhs.line2 == rhs.line2) &&
            (lhs.zipCode == rhs.zipCode) &&
            (lhs.city == rhs.city) &&
            (lhs.country == rhs.country)

    }

}

// MARK: - Country

/// A Raw Representable and Codable enum.
enum Country: String, Codable {
    case unitedStates = "United States"
    case france = "France"
}
