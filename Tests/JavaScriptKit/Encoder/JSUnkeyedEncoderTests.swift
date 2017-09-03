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

    func testEncodeValues() throws {

        let array = EncodableArray()
        array.append("Hello, world!")
        array.append(Int(1))
        array.append(Int8(2))

        let encoder = JSArgumentEncoder()
        let encodedArray = try encoder.encode(array)

        print(encodedArray)

    }

}

class AnyEncodable: Encodable {

    let performEncoding: (Encoder) throws -> Void

    init<T: Encodable>(_ base: T) {

        performEncoding = {
            try base.encode(to: $0)
        }

    }

    func encode(to encoder: Encoder) throws {
        try performEncoding(encoder)
    }

}

class EncodableArray: Encodable {

    var array = [AnyEncodable]()

    func append<T: Encodable>(_ value: T) {
        array.append(AnyEncodable(value))
    }

    func encode(to encoder: Encoder) throws {

        var unkeyedContainer = encoder.unkeyedContainer()

        for value in array {
            try unkeyedContainer.encode(value)
        }

    }

}
