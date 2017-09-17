import XCTest
import Foundation
@testable import JavaScriptKit

///
/// Tests decoding objects inside a keyed container.
///

class JSKeyedDecodingTests: XCTestCase {

    /// Tests decoding a JSON object.
    func testDecodeObject() throws {

        let jsonAddress: [AnyHashable: Any] = [
            "line1": "Apple Inc.",
            "line2": "1 Infinite Loop",
            "zipCode": 95014,
            "city": "Cupertino",
            "country": "United States"
        ]

        let decoder = JSResultDecoder()
        let decodedAddress: Address = try decoder.decode(jsonAddress)

        let expectedAddress = Address(line1: "Apple Inc.",
                                      line2: "1 Infinite Loop",
                                      zipCode: 95014,
                                      city: "Cupertino",
                                      country: .unitedStates)

        XCTAssertEqual(decodedAddress, expectedAddress)

    }

    /// Tests decoding a JSON object that contains optional fields.
    func testEncodeObjectWithOptionalFields() throws {

        let jsonAddress: [AnyHashable: Any] = [
            "line1": "1 Infinite Loop",
            "zipCode": 95014,
            "city": "Cupertino",
            "country": "United States"
        ]

        let decoder = JSResultDecoder()
        let decodedAddress: Address = try decoder.decode(jsonAddress)

        let expectedAddress = Address(line1: "1 Infinite Loop",
                                      line2: nil,
                                      zipCode: 95014,
                                      city: "Cupertino",
                                      country: .unitedStates)

        XCTAssertEqual(decodedAddress, expectedAddress)

    }

    /// Tests decoding a JSON object with nested objects.
    func testDecodeNestedObjects() throws {

        let jsonObject: [String: Any] = [
            "name": "Apple",
            "address": [
                "line1": "1 Infinite Loop",
                "zipCode": 95014,
                "city": "Cupertino",
                "country": "United States"
            ],
            "childCompanies": [
                [
                    "name": "Apple France",
                    "address": [
                        "line1": "7 Place d'Iéna",
                        "zipCode": 75116,
                        "city": "Paris XVIÈ",
                        "country": "France"
                    ],
                    "childCompanies": [],
                ]
            ]
        ]

        let decoder = JSResultDecoder()
        let decodedApple: Company = try decoder.decode(jsonObject)

        // Expected values

        let campus = Address(line1: "1 Infinite Loop",
                             line2: nil,
                             zipCode: 95014,
                             city: "Cupertino",
                             country: .unitedStates)

        let campusFR = Address(line1: "7 Place d'Iéna",
                               line2: nil,
                               zipCode: 75116,
                               city: "Paris XVIÈ",
                               country: .france)

        var apple = Company(name: "Apple",
                            address: campus,
                            childCompanies: [])

        let appleFrance = Company(name: "Apple France",
                                  address: campusFR,
                                  childCompanies: [])

        apple.childCompanies.append(appleFrance)

        XCTAssertEqual(decodedApple, apple)

    }

    /// Tests decoding an array of JSON objects.
    func testDecodeObjectList() throws {

        let jsonArray: [Any] = [
            [
                "name": "Apple",
                "address": [
                    "line1": "1 Infinite Loop",
                    "zipCode": 95014,
                    "city": "Cupertino",
                    "country": "United States"
                ],
                "childCompanies": []
            ],
            [
                "name": "Google",
                "address": [
                    "line1": "1600 Amphitheatre Parkway",
                    "zipCode": 94043,
                    "city": "Mountain View",
                    "country": "United States"
                ],
                "childCompanies": []
            ],
            [
                "name": "Facebook",
                "address": [
                    "line1": "1 Hacker Way",
                    "zipCode": 94025,
                    "city": "Menlo Park",
                    "country": "United States"
                ],
                "childCompanies": []
            ],
        ]

        let decoder = JSResultDecoder()
        let decodedCompanies: [Company] = try decoder.decode(jsonArray)

        // Expected values

        let appleCampus = Address(line1: "1 Infinite Loop",
                                  line2: nil,
                                  zipCode: 95014,
                                  city: "Cupertino",
                                  country: .unitedStates)

        let apple = Company(name: "Apple", address: appleCampus, childCompanies: [])

        let googlePlex = Address(line1: "1600 Amphitheatre Parkway",
                                 line2: nil,
                                 zipCode: 94043,
                                 city: "Mountain View",
                                 country: .unitedStates)

        let google = Company(name: "Google", address: googlePlex, childCompanies: [])

        let facebookHQ = Address(line1: "1 Hacker Way",
                                 line2: nil,
                                 zipCode: 94025,
                                 city: "Menlo Park",
                                 country: .unitedStates)

        let facebook = Company(name: "Facebook", address: facebookHQ, childCompanies: [])

        let expectedCompanies = [apple, google, facebook]

        XCTAssertEqual(decodedCompanies, expectedCompanies)

    }

}
