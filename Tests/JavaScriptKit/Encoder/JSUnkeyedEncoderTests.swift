import XCTest
import Foundation
@testable import JavaScriptKit

///
/// Tests encoding a list inside a JavaScript encoder.
///

class JSUnkeyedEncoderTests: XCTestCase {

    /// Tests encoding an array of Strings.
    func testEncodeStringArray() throws {

        let stringArray = ["abc", "def", "ghi"]
        let encoder = JSArgumentEncoder()
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

        let encoder = JSArgumentEncoder()
        let encodedArray = try encoder.encode(array)

        let expectedEncodedArray = "[[\"foo\",\"bar\"],[\"hello\",\"world\"]]"
        XCTAssertEqual(encodedArray, expectedEncodedArray)

    }

    /// Tests encoding
    func testNestedKeyedContainer() throws {

        let users = [
            [User(displayName: "Elon Musk", handle: "elon_musk")],
            [User(displayName: "Tim Cook", handle: "tim_cook")]
        ]

        let encoder = JSArgumentEncoder()
        let encodedArray = try encoder.encode(users)

        let expectedEncodedArray = "[[{\"displayName\":\"Elon Musk\",\"handle\":\"elon_musk\"}],[{\"displayName\":\"Tim Cook\",\"handle\":\"tim_cook\"}]]"

        XCTAssertEqual(encodedArray, expectedEncodedArray)

    }

}
