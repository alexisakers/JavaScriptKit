//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import XCTest
import Foundation
@testable import JavaScriptKit

/**
 * Tests decoding unkeyed sequences from JavaScript.
 */

class UnkeyedDecoderTests: XCTestCase {

    /// Tests decoding an array of Strings.
    func testDecodeStringArray() throws {
        let decoder = JavaScriptDecoder()
        let array = ["abc", "def", "ghi"]

        let decodedArray: [String] = try decoder.decode(array)
        XCTAssertEqual(decodedArray, array)
    }

    /// Tests decoding an array with nested arrays.
    func testDecodeNestedArray() throws {
        let array: [[String]] = [
            ["foo", "bar"],
            ["hello", "world"]
        ]

        let decoder = JavaScriptDecoder()
        let decodedArray: [[String]] = try decoder.decode(array)

        XCTAssertDeepEqual(decodedArray, array)
    }

    /// Tests decoding an array with nested keyed containers.
    func testNestedKeyedContainer() throws {
        let encodedUsers = [
            [
                ["displayName": "Brita Filter", "handle": "brita_filter"],
                ["displayName": "Roxy Moron", "handle": "roxy_moron"]
            ],
            [
                ["displayName": "Tim", "handle": "tim"],
                ["displayName": "Craig", "handle": "hair_force_1"]
            ]
        ]

        let decoder = JavaScriptDecoder()
        let decodedArray: [[User]] = try decoder.decode(encodedUsers)

        let expectedUsers = [
            [
                User(displayName: "Brita Filter", handle: "brita_filter"),
                User(displayName: "Roxy Moron", handle: "roxy_moron")
            ],
            [
                User(displayName: "Tim", handle: "tim"),
                User(displayName: "Craig", handle: "hair_force_1")
            ]
        ]

        XCTAssertDeepEqual(decodedArray, expectedUsers)
    }

}
