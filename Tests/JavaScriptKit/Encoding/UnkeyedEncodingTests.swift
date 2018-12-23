//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import XCTest
import Foundation
@testable import JavaScriptKit

/**
 * Tests encoding a list inside a JavaScript encoder.
 */

class UnkeyedEncodingTests: XCTestCase {

    /// Tests encoding an array of Strings.
    func testEncodeStringArray() throws {
        let stringArray = ["abc", "def", "ghi"]
        let encoder = JavaScriptEncoder()
        let encodedArray = try encoder.encode(stringArray)

        let expectedEncodedArray = "[\"abc\",\"def\",\"ghi\"]"
        XCTAssertEqual(encodedArray, expectedEncodedArray)
    }

    /// Tests encoding an array with nested arrays.
    func testEncodeNestedArray() throws {
        let array: [[String]] = [
            ["foo", "bar"],
            ["hello", "world"]
        ]

        let encoder = JavaScriptEncoder()
        let encodedArray = try encoder.encode(array)

        let expectedEncodedArray = "[[\"foo\",\"bar\"],[\"hello\",\"world\"]]"
        XCTAssertEqual(encodedArray, expectedEncodedArray)
    }

    /// Tests encoding an array with nested keyed containers.
    func testNestedKeyedContainer() throws {
        let users = [
            [User(displayName: "Brita Filter", handle: "brita_filter")],
            [User(displayName: "Roxy Moron", handle: "roxy_moron")]
        ]

        let encoder = JavaScriptEncoder()
        let encodedArray = try encoder.encode(users)

        let encodedPayload = try JSONSerialization.jsonObject(with: Data(encodedArray.utf8), options: []) as! [[[String: Any]]]

        let expectedEncodedUsers = [
            [
                ["displayName": "Brita Filter", "handle": "brita_filter"],
            ],
            [
                ["displayName": "Roxy Moron", "handle": "roxy_moron"],
            ]
        ]

        XCTAssertDeepEqual(encodedPayload, expectedEncodedUsers)
    }

}
