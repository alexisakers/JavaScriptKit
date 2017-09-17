import XCTest
import Foundation
@testable import JavaScriptKit

///
/// Tests encoding a single value inside a JavaScript encoder.
///

class SingleValueEncodingTests: XCTestCase {

    /// Tests encoding a `nil` value.
    func testEncodeNil() throws {

        let encoder = JavaScriptEncoder()

        let null: String? = nil
        let encodedNull = try encoder.encode(null)
        XCTAssertEqual(encodedNull, "null")

        let nonNull: String? = "This is nil, this me, I'm exactly where I'm supposed to be 🎶"
        let encodedNonNull = try encoder.encode(nonNull)
        XCTAssertEqual(encodedNonNull, doubleQuote(nonNull!.escapingSpecialCharacters))

    }

    /// Tests encoding Boolean values.
    func testEncodeBool() throws {

        let encoder = JavaScriptEncoder()

        let trueValue = true
        let encodedTrue = try encoder.encode(trueValue)
        XCTAssertEqual(encodedTrue, "true")

        let falseValue = false
        let encodedFalse = try encoder.encode(falseValue)
        XCTAssertEqual(encodedFalse, "false")

    }

    /// Tests encoding integer values.
    func testEncodeIntegers() throws {

        let encoder = JavaScriptEncoder()

        let int = Int(-500)
        let encodedInt = try encoder.encode(int)
        XCTAssertEqual(encodedInt, "-500")

        let int8 = Int8(-50)
        let encodedInt8 = try encoder.encode(int8)
        XCTAssertEqual(encodedInt8, "-50")

        let int16 = Int16(-5000)
        let encodedInt16 = try encoder.encode(int16)
        XCTAssertEqual(encodedInt16, "-5000")

        let int32 = Int32(-1234567890)
        let encodedInt32 = try encoder.encode(int32)
        XCTAssertEqual(encodedInt32, "-1234567890")

        #if arch(arm64) || arch(x86_64)
            let int64 = Int64(-1234567890987654321)
            let encodedInt64 = try encoder.encode(int64)
            XCTAssertEqual(encodedInt64, "-1234567890987654321")
        #endif

        let uint = UInt(500)
        let encodedUInt = try encoder.encode(uint)
        XCTAssertEqual(encodedUInt, "500")

        let uint8 = UInt8(50)
        let encodedUInt8 = try encoder.encode(uint8)
        XCTAssertEqual(encodedUInt8, "50")

        let uint16 = UInt16(5000)
        let encodedUInt16 = try encoder.encode(uint16)
        XCTAssertEqual(encodedUInt16, "5000")

        let uint32 = UInt32(1234567890)
        let encodedUInt32 = try encoder.encode(uint32)
        XCTAssertEqual(encodedUInt32, "1234567890")

        #if arch(arm64) || arch(x86_64)
            let uint64 = UInt64(1234567890987654321)
            let encodedUInt64 = try encoder.encode(uint64)
            XCTAssertEqual(encodedUInt64, "1234567890987654321")
        #endif

    }

    /// Tests encoding Float values.
    func testEncodeFloat() throws {

        let encoder = JavaScriptEncoder()

        let positiveFloat: Float = 255.8765
        let encodedPositiveFloat = try encoder.encode(positiveFloat)
        XCTAssertEqual(encodedPositiveFloat, "255.8765")

        let negativeFloat: Float = -2567
        let encodedNegativeFloat = try encoder.encode(negativeFloat)
        XCTAssertEqual(encodedNegativeFloat, "-2567")

        let positiveInfinity: Float = Float.infinity
        let encodedPositiveInfinity = try encoder.encode(positiveInfinity)
        XCTAssertEqual(encodedPositiveInfinity, "Number.POSITIVE_INFINITY")

        let negativeInfinity: Float = -Float.infinity
        let encodedNegativeInfinity = try encoder.encode(negativeInfinity)
        XCTAssertEqual(encodedNegativeInfinity, "Number.NEGATIVE_INFINITY")

        let NaN = Float(0) / Float(0)
        let encodedNaN = try encoder.encode(NaN)
        XCTAssertEqual(encodedNaN, "Number.NaN")

    }

    /// Tests encoding Double values.
    func testEncodeDouble() throws {

        let encoder = JavaScriptEncoder()

        let positiveDouble: Double = 255.87654
        let encodedPositiveDouble = try encoder.encode(positiveDouble)
        XCTAssertEqual(encodedPositiveDouble, "255.87654")

        let negativeDouble: Double = -2567.34560
        let encodedNegativeDouble = try encoder.encode(negativeDouble)
        XCTAssertEqual(encodedNegativeDouble, "-2567.3456")

        let positiveInfinity: Double = Double.infinity
        let encodedPositiveInfinity = try encoder.encode(positiveInfinity)
        XCTAssertEqual(encodedPositiveInfinity, "Number.POSITIVE_INFINITY")

        let negativeInfinity: Double = -Double.infinity
        let encodedNegativeInfinity = try encoder.encode(negativeInfinity)
        XCTAssertEqual(encodedNegativeInfinity, "Number.NEGATIVE_INFINITY")

        let NaN = Double(0) / Double(0)
        let encodedNaN = try encoder.encode(NaN)
        XCTAssertEqual(encodedNaN, "Number.NaN")

    }

    /// Tests encoding a String.
    func testEncodeString() throws {

        let string = "'Hello, world !'"
        let encoder = JavaScriptEncoder()
        let encodedString = try encoder.encode(string)

        XCTAssertEqual(encodedString, doubleQuote("\\u{27}Hello, world !\\u{27}"))

    }

    /// Tests encoding a URL.
    func testEncodeURL() throws {

        let url = URL(string: "https://developer.apple.com/reference/WebKit")!
        let encoder = JavaScriptEncoder()
        let encodedURL = try encoder.encode(url)
        XCTAssertEqual(encodedURL, doubleQuote("https://developer.apple.com/reference/WebKit"))

    }

    /// Tests encoding a Date.
    func testEncodeDate() throws {

        let date = Date(timeIntervalSince1970: 928274520)
        let encoder = JavaScriptEncoder()
        let encodedDate = try encoder.encode(date)
        XCTAssertEqual(encodedDate, "new Date(928274520000)")

    }

    /// Tests encoding an empty object.
    func testEncodeEmptyObject() throws {

        let emptyObject = EmptyObject()
        let encoder = JavaScriptEncoder()
        let encodedObject = try encoder.encode(emptyObject)
        XCTAssertEqual(encodedObject, "{}")

    }

    /// Tests that encoding an object that doesn't encode a value throws an error.
    func testNoEncodedValue() {

        let void = EmptyObject.Void()
        let encoder = JavaScriptEncoder()

        let errorExpectation = expectation(description: "Encoding an object that doesn't encode a value throws an error")
        let deadline = DispatchTime.now() + DispatchTimeInterval.seconds(1)

        DispatchQueue.global().asyncAfter(deadline: deadline) {

            do {
                let _ = try encoder.encode(void)
                XCTFail("An error should have been thrown because the `Encodable` implementation of `EmptyObject.Void` doesn't do anything.")
            } catch {
                errorExpectation.fulfill()
            }

        }

        wait(for: [errorExpectation], timeout: 10)

    }

    // MARK: - Utilities

    func doubleQuote(_ string: String) -> String {
        return "\"" + string + "\""
    }

}
