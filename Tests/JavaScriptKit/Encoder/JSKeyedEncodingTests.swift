import XCTest
import Foundation
@testable import JavaScriptKit

///
/// Tests encoding objects inside a keyed container.
///

class JSKeyedEncodingTests: XCTestCase {

    /// Tests encoding a JSON object.
    func testEncodeObject() throws {

        let encoder = JSArgumentEncoder()

        let address = Address(line1: "Mickey Mouse Clubhouse",
                              line2: "Somewhere over the rainbow",
                              zipCode: 12345,
                              city: "Mickey Park",
                              country: .utopia)

        let encodedAddress1 = try encoder.encode(address).data(using: .utf8)!

        guard let encodedAddressJSON = try JSONSerialization.jsonObject(with: encodedAddress1, options: []) as? NSDictionary else {
            XCTFail("Encoded didn't encode a valid JSON literal for the address structure.")
            return
        }

        let expectedJSONObject: [AnyHashable: Any] = [
            "line1": "Mickey Mouse Clubhouse",
            "line2": "Somewhere over the rainbow",
            "zipCode": 12345,
            "city": "Mickey Park",
            "country": "UTOPIA"
        ]

        XCTAssertTrue(encodedAddressJSON.isEqual(to: expectedJSONObject))

    }

    /// Tests encoding a JSON object that contains optional fields.
    func testEncodeObjectWithOptionalFields() throws {

        let encoder = JSArgumentEncoder()

        let address = Address(line1: "Mickey Mouse Clubhouse",
                              line2: nil,
                              zipCode: 12345,
                              city: "Mickey Park",
                              country: .utopia)

        let encodedAddress1 = try encoder.encode(address).data(using: .utf8)!

        guard let encodedAddressJSON = try JSONSerialization.jsonObject(with: encodedAddress1, options: []) as? NSDictionary else {
            XCTFail("Encoded didn't encode a valid JSON literal for the address structure.")
            return
        }

        let expectedJSONObject: [AnyHashable: Any] = [
            "line1": "Mickey Mouse Clubhouse",
            "zipCode": 12345,
            "city": "Mickey Park",
            "country": "UTOPIA"
        ]

        XCTAssertTrue(encodedAddressJSON.isEqual(to: expectedJSONObject))

    }

    /// Tests encoding a JSON object with nested objects.
    func testEncodeNestedObjects() throws {

        let clubhouse = Address(line1: "Mickey Mouse Clubhouse",
                                line2: nil,
                                zipCode: 12345,
                                city: "Mickey Park",
                                country: .utopia)

        var mickey = Person(firstName: "Mickey",
                            lastName: "Mouse",
                            birthDate: Date(timeIntervalSince1970: -1297598400),
                            mainAddress: clubhouse,
                            socialMediaURL: URL(string: "https://example.com/@mickey")!,
                            bestFriends: nil)

        let minnie = Person(firstName: "Minnie",
                            lastName: "Mouse",
                            birthDate: Date(timeIntervalSince1970: -1297598400),
                            mainAddress: clubhouse,
                            socialMediaURL: URL(string: "https://example.com/@minnie")!,
                            bestFriends: nil)

        let donald = Person(firstName: "Donald",
                            lastName: "Duck",
                            birthDate: Date(timeIntervalSince1970: -1122292800),
                            mainAddress: clubhouse,
                            socialMediaURL: URL(string: "https://example.com/@donald")!,
                            bestFriends: nil)

        mickey.bestFriends = [minnie, donald]

        let encoder = JSArgumentEncoder()
        let encodedGraph = try encoder.encode(mickey).data(using: .utf8)!

        guard let jsonObjectGraph = try JSONSerialization.jsonObject(with: encodedGraph, options: []) as? NSDictionary else {
            XCTFail("Encoded didn't encode a valid JSON literal for the object graph.")
            return
        }

        let expectedGraph: [AnyHashable: Any] = [
            "firstName": "Mickey",
            "lastName": "Mouse",
            "birthDate": -1297598400000,
            "mainAddress": [
                "line1": "Mickey Mouse Clubhouse",
                "zipCode": 12345,
                "city": "Mickey Park",
                "country": "UTOPIA"
            ],
            "socialMediaURL": "https://example.com/@mickey",
            "bestFriends": [
                [
                    "firstName": "Minnie",
                    "lastName": "Mouse",
                    "birthDate": -1297598400000,
                    "mainAddress": [
                        "line1": "Mickey Mouse Clubhouse",
                        "zipCode": 12345,
                        "city": "Mickey Park",
                        "country": "UTOPIA"
                    ],
                    "socialMediaURL": "https://example.com/@minnie"
                ],
                [
                    "firstName": "Donald",
                    "lastName": "Duck",
                    "birthDate": -1122292800000,
                    "mainAddress": [
                        "line1": "Mickey Mouse Clubhouse",
                        "zipCode": 12345,
                        "city": "Mickey Park",
                        "country": "UTOPIA"
                    ],
                    "socialMediaURL": "https://example.com/@donald"
                ]
            ]
        ]

        XCTAssertTrue(jsonObjectGraph.isEqual(to: expectedGraph))

    }

    /// Tests encoding an array of JSON objects.
    func testEncodeObjectList() throws {

        let clubhouse = Address(line1: "Mickey Mouse Clubhouse",
                                line2: nil,
                                zipCode: 12345,
                                city: "Mickey Park",
                                country: .utopia)

        let mickey = Person(firstName: "Mickey",
                            lastName: "Mouse",
                            birthDate: Date(timeIntervalSince1970: -1297598400),
                            mainAddress: clubhouse,
                            socialMediaURL: URL(string: "https://example.com/@mickey")!,
                            bestFriends: nil)

        let minnie = Person(firstName: "Minnie",
                            lastName: "Mouse",
                            birthDate: Date(timeIntervalSince1970: -1297598400),
                            mainAddress: clubhouse,
                            socialMediaURL: URL(string: "https://example.com/@minnie")!,
                            bestFriends: nil)

        let donald = Person(firstName: "Donald",
                            lastName: "Duck",
                            birthDate: Date(timeIntervalSince1970: -1122292800),
                            mainAddress: clubhouse,
                            socialMediaURL: URL(string: "https://example.com/@donald")!,
                            bestFriends: nil)

        let encoder = JSArgumentEncoder()
        let encodedGraph = try encoder.encode([mickey, minnie, donald]).data(using: .utf8)!

        guard let jsonObjectList = try JSONSerialization.jsonObject(with: encodedGraph, options: []) as? NSArray else {
            XCTFail("Encoded didn't encode a valid JSON array literal for the object graph.")
            return
        }

        let expectedList: [Any] = [
            ["firstName": "Mickey",
            "lastName": "Mouse",
            "birthDate": -1297598400000,
            "mainAddress": [
                "line1": "Mickey Mouse Clubhouse",
                "zipCode": 12345,
                "city": "Mickey Park",
                "country": "UTOPIA"
            ],
            "socialMediaURL": "https://example.com/@mickey",
            ],
            [
                "firstName": "Minnie",
                "lastName": "Mouse",
                "birthDate": -1297598400000,
                "mainAddress": [
                    "line1": "Mickey Mouse Clubhouse",
                    "zipCode": 12345,
                    "city": "Mickey Park",
                    "country": "UTOPIA"
                ],
                "socialMediaURL": "https://example.com/@minnie"
            ],
            [
                "firstName": "Donald",
                "lastName": "Duck",
                "birthDate": -1122292800000,
                "mainAddress": [
                    "line1": "Mickey Mouse Clubhouse",
                    "zipCode": 12345,
                    "city": "Mickey Park",
                    "country": "UTOPIA"
                ],
                "socialMediaURL": "https://example.com/@donald"
            ]
        ]

        XCTAssertTrue(jsonObjectList.isEqual(to: expectedList))

    }

}
