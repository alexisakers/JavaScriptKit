import XCTest
import Foundation
@testable import JavaScriptKit

class JSSingleValueDecoderTests: XCTestCase {

    func testDecodeString() throws {

        let string = "Hello, world!"
        let decodedString: String = try JSResultDecoder().decode(string)
        XCTAssertEqual(decodedString, string)

    }

    func testDecodeBool() throws {

        let falseBool = false
        let decodedFalse: Bool = try JSResultDecoder().decode(falseBool)
        XCTAssertEqual(decodedFalse, falseBool)

        let trueBool = true
        let decodedTrue: Bool = try JSResultDecoder().decode(trueBool)
        XCTAssertEqual(decodedTrue, trueBool)

    }

    func testDecodeIntegers() throws {

        let decoder = JSResultDecoder()

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

    /// Tests that decoding a number that doesn't fit into the requested type throws an error.
    func testMaxIntegerOverflowDecodingError() {

        let decoder = JSResultDecoder()
        let failureExpectation = expectation(description: "decoding a number that doesn't fit into the requested type")
        let deadline = DispatchTime.now() + DispatchTimeInterval.seconds(2)

        DispatchQueue.main.asyncAfter(deadline: deadline) {

            do {
                let int: Int = 500
                let int8: Int8 = try decoder.decode(int)
                XCTFail("Int value shouldn't be decoded because it cannot fit into Int8 (\(int8)).")
            } catch {
                failureExpectation.fulfill()
            }

        }

        wait(for: [failureExpectation], timeout: 5)

    }

    /// Tests that decoding a number that doesn't fit into the requested type throws an error.
    func testMinIntegerOverflowDecodingError() {

        let decoder = JSResultDecoder()
        let failureExpectation = expectation(description: "decoding a number that doesn't fit into the requested type")
        let deadline = DispatchTime.now() + DispatchTimeInterval.seconds(2)

        DispatchQueue.main.asyncAfter(deadline: deadline) {

            do {
                let int: Int = -100
                let uint8: UInt8 = try decoder.decode(int)
                XCTFail("Int value shouldn't be decoded because it cannot fit into Int8 (\(uint8)).")
            } catch {
                failureExpectation.fulfill()
            }

        }

        wait(for: [failureExpectation], timeout: 5)

    }

}
