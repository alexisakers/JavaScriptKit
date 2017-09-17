import XCTest
import Foundation
@testable import JavaScriptKit

///
/// Tests decoding unkeyed sequences from JavaScript.
///

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
                ["displayName": "Elon Musk", "handle": "elon_musk"],
                ["displayName": "Mark Zuckerberg", "handle": "mark"]
            ],
            [
                ["displayName": "Tim Cook", "handle": "tim_cook"],
                ["displayName": "Craig", "handle": "hair_force_1"]
            ]
        ]

        let decoder = JavaScriptDecoder()
        let decodedArray: [[User]] = try decoder.decode(encodedUsers)

        let expectedUsers = [
            [
                User(displayName: "Elon Musk", handle: "elon_musk"),
                User(displayName: "Mark Zuckerberg", handle: "mark")
            ],
            [
                User(displayName: "Tim Cook", handle: "tim_cook"),
                User(displayName: "Craig", handle: "hair_force_1")
            ]
        ]

        XCTAssertDeepEqual(decodedArray, expectedUsers)

    }

}
