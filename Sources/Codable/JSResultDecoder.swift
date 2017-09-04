/**
 *  JavaScriptKit
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// Decodes JavaScript expression return values to a `Decodable` value.
///

final class JSResultDecoder {

    func decode<T: Decodable>(_ value: Any) throws -> T {

        let container: JSCodingContainer

        if let dictionary = value as? NSDictionary {
            let storage = DictionaryStorage(dictionary)
            container = .keyed(storage)
        } else if let array = value as? NSArray {
            let storage = ArrayStorage(array)
            container = .unkeyed(storage)
        } else {
            let storage = try decodeSingleValue(value)
            container = .singleValue(storage)
        }

        throw NSError()

    }

    private func decodeSingleValue(_ value: Any) throws -> SingleValueStorage {

        if value is NSNull {
            return .null
        } else if value is Bool {
            return .boolean(value as! Bool)
        } else if value is String {
            return .string(value as! String)
        } else if value is Date {
            return .date(value as! Date)
        } else if value is NSNumber {

        }

        let context = DecodingError.Context(codingPath: [], debugDescription: "Could not decode \(value) because it is not of a supported type. Supported types include null, booleans, strings, dates, numbers, arrays and objects.")
        throw DecodingError.dataCorrupted(context)

    }

}
