//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import XCTest
import Foundation
@testable import JavaScriptKit

/**
 * Tests decoding single values.
 */

class SingleValueDecodingTests: XCTestCase {

    /// Tests decoding a String.
    func testDecodeString() throws {
        let string = "Hello, world!"
        let decodedString: String = try JavaScriptDecoder().decode(string)
        XCTAssertEqual(decodedString, string)
    }

    /// Tests decoding a Boolean.
    func testDecodeBool() throws {
        let falseBool = false
        let decodedFalse: Bool = try JavaScriptDecoder().decode(falseBool)
        XCTAssertEqual(decodedFalse, falseBool)

        let trueBool = true
        let decodedTrue: Bool = try JavaScriptDecoder().decode(trueBool)
        XCTAssertEqual(decodedTrue, trueBool)
    }

    /// Tests decoding integers.
    func testDecodeIntegers() throws {
        let decoder = JavaScriptDecoder()

        let int = Int(-500)
        let decodedInt: Int = try decoder.decode(int)
        XCTAssertEqual(decodedInt, decodedInt)

        let int8 = Int8(-50)
        let decodedInt8: Int8 = try decoder.decode(int8)
        XCTAssertEqual(decodedInt8, decodedInt8)

        let int16 = Int16(-5000)
        let decodedInt16: Int64 = try decoder.decode(int16)
        XCTAssertEqual(decodedInt16, decodedInt16)

        let int32 = Int32(-1234567890)
        let decodedInt32: Int32 = try decoder.decode(int32)
        XCTAssertEqual(decodedInt32, decodedInt32)

        #if arch(arm64) || arch(x86_64)
            let int64 = Int64(-1234567890987654321)
            let decodedInt64: Int64 = try decoder.decode(int64)
            XCTAssertEqual(decodedInt64, decodedInt64)
        #endif

        let uint = UInt(500)
        let decodedUInt: UInt = try decoder.decode(uint)
        XCTAssertEqual(decodedUInt, decodedUInt)

        let uint8 = UInt8(50)
        let decodedUInt8: UInt8 = try decoder.decode(uint8)
        XCTAssertEqual(decodedUInt8, decodedUInt8)

        let uint16 = UInt16(5000)
        let decodedUInt16: UInt16 = try decoder.decode(uint16)
        XCTAssertEqual(decodedUInt16, uint16)

        let uint32 = UInt32(1234567890)
        let decodedUInt32: UInt32 = try decoder.decode(uint32)
        XCTAssertEqual(decodedUInt32, uint32)

        #if arch(arm64) || arch(x86_64)
            let uint64 = UInt64(1234567890987654321)
            let decodedUInt64: UInt64 = try decoder.decode(uint64)
            XCTAssertEqual(decodedUInt64, uint64)
        #endif
    }

    /// Tests decoding a Date.
    func testDecodeDate() throws {
        let decoder = JavaScriptDecoder()

        let intTimeInterval: Int = 1504602844000
        let decodedIntDate: Date = try decoder.decode(intTimeInterval)
        XCTAssertEqual(decodedIntDate, Date(timeIntervalSince1970: Double(intTimeInterval) / 1000))

        let doubleTimeInterval: Double = 1404602844000
        let decodedDoubleDate: Date = try decoder.decode(doubleTimeInterval)
        XCTAssertEqual(decodedDoubleDate, Date(timeIntervalSince1970: doubleTimeInterval / 1000))

        let floatTimeInterval: Float = 1604602844000
        let decodedFloatDate: Date = try decoder.decode(floatTimeInterval)
        XCTAssertEqual(decodedFloatDate, Date(timeIntervalSince1970: Double(floatTimeInterval) / 1000))

        let date = Date()
        let decodedDate: Date = try decoder.decode(date)
        XCTAssertEqual(decodedDate, date)
    }

    /// Tests decoding a URL.
    func testDecodeURL() throws {
        let decoder = JavaScriptDecoder()

        let urlString = "https://developer.apple.com/reference/JavaScriptCore"
        let decodedURL: URL = try decoder.decode(urlString)
        XCTAssertEqual(decodedURL.absoluteString, urlString)
    }

    /// Tests decoding a UUID.
    func testDecodeUUID() throws {
        let decoder = JavaScriptDecoder()

        let uuidString = "B011902E-0D68-4889-A459-77AE18E8616E"
        let decodedUUID: UUID = try decoder.decode(uuidString)
        XCTAssertEqual(decodedUUID.uuidString, uuidString)
    }

    /// Tests decoding a CGFloat.
    func testDecodeCGFloat() throws {
        let decoder = JavaScriptDecoder()

        let float: Float = 1604602844000
        let decodedFloat: CGFloat = try decoder.decode(float)

        XCTAssertEqual(decodedFloat, CGFloat(float))
    }

    /// Tests that an error is thrown when the decoded type does not match the encoded value type.
    func testTypeError() {
        let decoder = JavaScriptDecoder()

        let string = "Hello, world!"
        let decode = {
            let int: Int = try decoder.decode(string)
            print(int)
        }

        XCTAssertThrowsError(try decode()) { error in
            guard case let DecodingError.typeMismatch(attemptedType, context) = error else {
                return XCTFail("Invalid error: \(error).")
            }

            XCTAssertTrue(attemptedType == String.self)
            XCTAssertEqual(context.debugDescription, "Cannot decode `Int` because value is of type `String`.")
        }
    }

}
