//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import XCTest
import Foundation
@testable import JavaScriptKit

/**
 * Tests Codable-supporting data structures and utilities.
 */

class CodableSupportTests: XCTestCase {

    // MARK: Single Value Storage

    /// Tests creating a single value storage.
    func testCreateSingleValueStorage() throws {
        let nullStorage = try SingleValueStorage(storedValue: NSNull())

        guard case .null = nullStorage else {
            return XCTFail("Should create a null storage.")
        }

        let stringStorage = try SingleValueStorage(storedValue: "Hello")

        switch stringStorage {
        case .string(let str):
            XCTAssertEqual(str, "Hello")
        default:
            XCTFail("Should create a string storage.")
        }

        let nsStringStorage = try SingleValueStorage(storedValue: "Hello" as NSString)

        switch nsStringStorage {
        case .string(let str):
            XCTAssertEqual(str, "Hello")
        default:
            XCTFail("Should create a string storage.")
        }

        let intStorage = try SingleValueStorage(storedValue: Int(100))

        switch intStorage {
        case .number(let num):
            XCTAssertEqual(num.intValue, 100)
        default:
            XCTFail("Should create a number storage.")
        }

        let doubleStorage = try SingleValueStorage(storedValue: Double(100.8765))

        switch doubleStorage {
        case .number(let num):
            XCTAssertEqual(num.doubleValue, 100.8765)
        default:
            XCTFail("Should create a number storage.")
        }

        let floatStorage = try SingleValueStorage(storedValue: Float(100.8765))

        switch floatStorage {
        case .number(let num):
            XCTAssertEqual(num.floatValue, 100.8765)
        default:
            XCTFail("Should create a number storage.")
        }

        let dateStorage = try SingleValueStorage(storedValue: Date.distantFuture)

        switch dateStorage {
        case .date(let date):
            XCTAssertEqual(date, .distantFuture)
        default:
            XCTFail("Should create a date storage.")
        }

        let invalidStorage = try? SingleValueStorage(storedValue: ReaderFont.sanFrancisco)
        XCTAssertNil(invalidStorage)
    }

    /// Tests getting the stored value from a single value storage.
    func testGetSingleValueStorageStoredValue() {
        let nullStorage = SingleValueStorage.null
        XCTAssertTrue(nullStorage.storedValue is NSNull)

        let stringStorage = SingleValueStorage.string("Hello")
        XCTAssertTrue(stringStorage.storedValue as? String == "Hello")

        let boolStorage = SingleValueStorage.boolean(true)
        XCTAssertTrue(boolStorage.storedValue as? Bool == true)

        let numberStorage = SingleValueStorage.number(100)
        XCTAssertTrue(numberStorage.storedValue as? NSNumber == 100)

        let dateStorage = SingleValueStorage.date(.distantFuture)
        XCTAssertTrue(dateStorage.storedValue as? Date == .distantFuture)

        let emptyStorage = SingleValueStorage.emptyObject
        XCTAssertTrue((emptyStorage.storedValue as? [String: Any])?.isEmpty == true)
    }

    /// Tests getting the stored type from a single value storage.
    func testGetSingleValueStorageStoredType() {
        let nullStorage = SingleValueStorage.null
        XCTAssertTrue(nullStorage.storedType == NSNull.self)

        let stringStorage = SingleValueStorage.string("Hello")
        XCTAssertTrue(stringStorage.storedType == String.self)

        let boolStorage = SingleValueStorage.boolean(true)
        XCTAssertTrue(boolStorage.storedType == Bool.self)

        let numberStorage = SingleValueStorage.number(100)
        XCTAssertTrue(numberStorage.storedType == NSNumber.self)

        let dateStorage = SingleValueStorage.date(.distantFuture)
        XCTAssertTrue(dateStorage.storedType == Date.self)

        let emptyStorage = SingleValueStorage.emptyObject
        XCTAssertTrue(emptyStorage.storedType == Dictionary<String, Any>.self)
    }

    // MARK: - JSONKey

    /// Tests internal JSON keys.
    func testJSONKey() {
        let superKey = JSONKey.super
        XCTAssertEqual(superKey.stringValue, "super")
        XCTAssertNil(superKey.intValue)

        let stringKey = JSONKey.string("foo")
        XCTAssertEqual(stringKey.stringValue, "foo")
        XCTAssertNil(stringKey.intValue)

        let indexKey = JSONKey.index(10)
        XCTAssertEqual(indexKey.stringValue, "Index 10")
        XCTAssertTrue(indexKey.intValue == 10)

        let barKey = JSONKey(stringValue: "bar")
        XCTAssertEqual(barKey.stringValue, "bar")
        XCTAssertNil(barKey.intValue)

        let startIndexKey = JSONKey(intValue: 0)
        XCTAssertEqual(startIndexKey.stringValue, "Index 0")
        XCTAssertTrue(startIndexKey.intValue == 0)
    }

}
