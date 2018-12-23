//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

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

/// A simple structure.
struct User: Codable, Hashable {
    let displayName: String
    let handle: String
}

// MARK: - Person

/// A structure with nested unkeyed containers containing keyed containers.
struct Company: Codable, Hashable {
    let name: String
    let address: Address
    var childCompanies: [Company]
}

// MARK: - Address

/// A structure with an optional field.
struct Address: Codable, Hashable {
    let line1: String
    let line2: String?
    let zipCode: Int
    let city: String
    let country: Country
}

// MARK: - Country

/// A Raw Representable and Codable enum.
enum Country: String, Codable {
    case unitedStates = "United States"
    case france = "France"
}
