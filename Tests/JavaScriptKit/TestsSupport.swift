import XCTest
import Foundation

func XCTAssertEqual(_ dictionary: [String: Any], _ expected: [String: Any]) {

    for (key, value) in dictionary {

        guard let expectedValue = expected[key] else {
            XCTFail("Unexpected value for key")
            break
        }

        if let hashable = value as? AnyHashable, let expectedHashable = expectedValue as? AnyHashable {
            XCTAssertEqual(hashable, expectedHashable)
            continue
        }

        if let array = value as? [AnyHashable], let expectedArray = expectedValue as? [AnyHashable] {
            XCTAssertEqual(array, expectedArray)
            continue
        }

        if let arrayArray = value as? [[AnyHashable]], let expectedArrayArray = expectedValue as? [[AnyHashable]] {

            XCTAssertEqual(arrayArray.count, expectedArrayArray.count)

            for (arr, expectedArr) in zip(arrayArray, expectedArrayArray) {
                XCTAssertEqual(arr, expectedArr)
            }

            continue
            
        }


        if let dictionary = value as? [String: Any], let expectedDictionary = expectedValue as? [String: Any] {
            XCTAssertEqual(dictionary, expectedDictionary)
            continue
        }

        if let dictionaryArray = value as? [[String: Any]], let expectedDictionaryArray = expectedValue as? [[String: Any]] {

            XCTAssertEqual(dictionaryArray.count, expectedDictionaryArray.count)

            for (dict, expectedDict) in zip(dictionaryArray, expectedDictionaryArray) {
                XCTAssertEqual(dict, expectedDict)
            }

            continue

        }

        XCTFail("Could not compare values for key \(key)")

    }

}
