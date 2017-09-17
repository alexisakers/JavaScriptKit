import XCTest
import Foundation
@testable import JavaScriptKit

///
/// Tests encoding objects inside a keyed container.
///

class KeyedEncodingTests: XCTestCase {

    /// Tests encoding a JSON object.
    func testEncodeObject() throws {

        let encoder = JavaScriptEncoder()

        let address = Address(line1: "Apple Inc.",
                              line2: "1 Infinite Loop",
                              zipCode: 95014,
                              city: "Cupertino",
                              country: .unitedStates)

        let encodedAddress1 = try encoder.encode(address).data(using: .utf8)!

        guard let encodedAddressJSON = try JSONSerialization.jsonObject(with: encodedAddress1, options: []) as? NSDictionary else {
            XCTFail("Encoded didn't encode a valid JSON literal for the address structure.")
            return
        }

        let expectedJSONObject: [AnyHashable: Any] = [
            "line1": "Apple Inc.",
            "line2": "1 Infinite Loop",
            "zipCode": 95014,
            "city": "Cupertino",
            "country": "United States"
        ]

        XCTAssertTrue(encodedAddressJSON.isEqual(to: expectedJSONObject))

    }

    /// Tests encoding a JSON object that contains optional fields.
    func testEncodeObjectWithOptionalFields() throws {

        let encoder = JavaScriptEncoder()

        let address = Address(line1: "1 Infinite Loop",
                              line2: nil,
                              zipCode: 95014,
                              city: "Cupertino",
                              country: .unitedStates)

        let encodedAddress1 = try encoder.encode(address).data(using: .utf8)!

        guard let encodedAddressJSON = try JSONSerialization.jsonObject(with: encodedAddress1, options: []) as? NSDictionary else {
            XCTFail("Encoded didn't encode a valid JSON literal for the address structure.")
            return
        }

        let expectedJSONObject: [AnyHashable: Any] = [
            "line1": "1 Infinite Loop",
            "zipCode": 95014,
            "city": "Cupertino",
            "country": "United States"
        ]

        XCTAssertTrue(encodedAddressJSON.isEqual(to: expectedJSONObject))

    }

    /// Tests encoding a JSON object with nested objects.
    func testEncodeNestedObjects() throws {

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

        let encoder = JavaScriptEncoder()
        let encodedGraph = try encoder.encode(apple).data(using: .utf8)!

        guard let jsonObjectGraph = try JSONSerialization.jsonObject(with: encodedGraph, options: []) as? [String: Any] else {
            XCTFail("Encoded didn't encode a valid JSON literal for the object graph.")
            return
        }

        let expectedGraph: [String: Any] = [
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
                        "line1": "7 Place d\\u{27}Iéna",
                        "zipCode": 75116,
                        "city": "Paris XVIÈ",
                        "country": "France"
                    ],
                    "childCompanies": [],
                ]
            ]
        ]

        XCTAssertDeepEqual(jsonObjectGraph, expectedGraph)

    }

    /// Tests encoding an array of JSON objects.
    func testEncodeObjectList() throws {

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

        let encoder = JavaScriptEncoder()
        let encodedGraph = try encoder.encode([apple, google, facebook]).data(using: .utf8)!

        guard let jsonObjectList = try JSONSerialization.jsonObject(with: encodedGraph, options: []) as? [Any] else {
            XCTFail("Encoded didn't encode a valid JSON array literal for the object graph.")
            return
        }

        let expectedList: [Any] = [
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

        XCTAssertDeepEqual(jsonObjectList, expectedList)

    }

}
