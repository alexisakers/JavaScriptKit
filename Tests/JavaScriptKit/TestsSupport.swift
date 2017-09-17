import XCTest
import Foundation

/// Checks if two dictionaries are equal.
func XCTAssertDeepEqual(_ dictionary: [String: Any], _ expected: [String: Any]) {

    for (key, value) in dictionary {

        guard let expectedValue = expected[key] else {
            XCTFail("Unexpected value for key")
            break
        }

        let didCompare = XCTDeepCompare(value, expectedValue)

        guard didCompare == true else {
            XCTFail("Could not compare values for key \(key)")
            return
        }

    }

}

/// Checks if two arrays are equal.
func XCTAssertDeepEqual(_ array: [Any], _ expected: [Any]) {

    guard array.count == expected.count else {
        XCTFail("Array does not have the expected number of items.")
        return
    }

    var idx = 0

    for (value, expectedValue) in zip(array, expected) {

        let didCompare = XCTDeepCompare(value, expectedValue)

        guard didCompare == true else {
            XCTFail("Could not compare values at index \(idx).")
            return
        }

        idx += 1

    }

}

private func XCTDeepCompare(_ value: Any, _ expectedValue: Any) -> Bool {

    if let hashable = value as? AnyHashable, let expectedHashable = expectedValue as? AnyHashable {
        XCTAssertEqual(hashable, expectedHashable)
        return true
    }

    if let array = value as? [AnyHashable], let expectedArray = expectedValue as? [AnyHashable] {
        XCTAssertEqual(array, expectedArray)
        return true
    }

    if let arrayArray = value as? [[AnyHashable]], let expectedArrayArray = expectedValue as? [[AnyHashable]] {

        XCTAssertEqual(arrayArray.count, expectedArrayArray.count)

        for (arr, expectedArr) in zip(arrayArray, expectedArrayArray) {
            XCTAssertEqual(arr, expectedArr)
        }

        return true

    }


    if let dictionary = value as? [String: Any], let expectedDictionary = expectedValue as? [String: Any] {
        XCTAssertDeepEqual(dictionary, expectedDictionary)
        return true
    }

    if let dictionaryArray = value as? [[String: Any]], let expectedDictionaryArray = expectedValue as? [[String: Any]] {

        XCTAssertEqual(dictionaryArray.count, expectedDictionaryArray.count)

        for (dict, expectedDict) in zip(dictionaryArray, expectedDictionaryArray) {
            XCTAssertDeepEqual(dict, expectedDict)
        }

        return true

    }

    return false

}
