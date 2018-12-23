//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import XCTest
import Foundation

/// Checks if two dictionaries are equal.
func XCTAssertDeepEqual(_ dictionary: [String: Any], _ expected: [String: Any], file: StaticString = #file, line: UInt = #line) {
    for (key, value) in dictionary {
        guard let expectedValue = expected[key] else {
            XCTFail("Unexpected value for key", file: file, line: line)
            break
        }

        let didCompare = XCTDeepCompare(value, expectedValue, file: file, line: line)

        guard didCompare == true else {
            XCTFail("Could not compare values for key \(key)", file: file, line: line)
            return
        }
    }

}

/// Checks if two arrays are equal.
func XCTAssertDeepEqual(_ array: [Any], _ expected: [Any], file: StaticString = #file, line: UInt = #line) {
    guard array.count == expected.count else {
        XCTFail("Array does not have the expected number of items.", file: file, line: line)
        return
    }

    var idx = 0

    for (value, expectedValue) in zip(array, expected) {
        let didCompare = XCTDeepCompare(value, expectedValue, file: file, line: line)

        guard didCompare == true else {
            XCTFail("Could not compare values at index \(idx).", file: file, line: line)
            return
        }

        idx += 1
    }
}

private func XCTDeepCompare(_ value: Any, _ expectedValue: Any, file: StaticString = #file, line: UInt = #line) -> Bool {
    if let array = value as? [AnyHashable], let expectedArray = expectedValue as? [AnyHashable] {
        XCTAssertEqual(array, expectedArray, file: file, line: line)
        return true
    }

    if let arrayArray = value as? [[AnyHashable]], let expectedArrayArray = expectedValue as? [[AnyHashable]] {
        XCTAssertEqual(arrayArray.count, expectedArrayArray.count)

        for (arr, expectedArr) in zip(arrayArray, expectedArrayArray) {
            XCTAssertEqual(arr, expectedArr, file: file, line: line)
        }

        return true
    }

    if let dictionary = value as? [String: Any], let expectedDictionary = expectedValue as? [String: Any] {
        XCTAssertDeepEqual(dictionary, expectedDictionary, file: file, line: line)
        return true
    }

    if let dictionaryArray = value as? [[String: Any]], let expectedDictionaryArray = expectedValue as? [[String: Any]] {
        XCTAssertEqual(dictionaryArray.count, expectedDictionaryArray.count, file: file, line: line)

        for (dict, expectedDict) in zip(dictionaryArray, expectedDictionaryArray) {
            XCTAssertDeepEqual(dict, expectedDict, file: file, line: line)
        }

        return true
    }

    if let hashable = value as? AnyHashable, let expectedHashable = expectedValue as? AnyHashable {
        XCTAssertEqual(hashable, expectedHashable, file: file, line: line)
        return true
    }

    return false
}
