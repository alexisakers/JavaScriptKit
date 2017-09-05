/**
 *  JavaScriptKit
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// Decodes JavaScript expression return values to a `Decodable` value.
///

final class JSResultDecoder {

    ///
    /// Decodes a value returned by a JavaScript expression and returns decodes it into the expected
    /// `Decodable` type.
    ///
    /// - parameter value: The value returned by the JavaScript expression.
    /// - returns: The JavaScript text representing the value.
    ///

    func decode<T: Decodable>(_ value: Any) throws -> T {

        //==== I- Serialize the top container ====//

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

        //==== II- Decode the container ====//

        let decoder = JSStructureDecoder(container: container)

        if T.self == URL.self || T.self == Date.self {
            let singleValueContainer = try decoder.singleValueContainer()
            return try singleValueContainer.decode(T.self)
        }

        return try T(from: decoder)

    }

    /// Unboxes the value as a single value container.
    private func decodeSingleValue(_ value: Any) throws -> SingleValueStorage {

        if value is NSNull {
            return .null
        } else if value is String {
            return .string(value as! String)
        } else if value is Date {
            return .date(value as! Date)
        } else if value is Bool {
            return .boolean(value as! Bool)
        } else if value is Double {
            return .double(value as! Double)
        } else if value is Float {
            return .float(value as! Float)
        } else if value is Int {
            let anyInteger = AnyInteger(value as! Int)
            return .integer(anyInteger)
        } else if value is NSNumber {

            let nsNumber = value as! NSNumber

            if nsNumber == kCFBooleanTrue || nsNumber == kCFBooleanFalse {
                return .boolean(nsNumber.boolValue)
            }
            
            let doubleValue = nsNumber.doubleValue

            if rint(doubleValue) == doubleValue {
                let anyInteger = AnyInteger(nsNumber.intValue)
                return .integer(anyInteger)
            }

            return .double(doubleValue)

        }

        let context = DecodingError.Context(codingPath: [], debugDescription: "Could not decode \(value) because it is not of a supported type. Supported types include null, booleans, strings, dates, numbers, arrays and objects.")
        throw DecodingError.dataCorrupted(context)

    }

}

// MARK: - Structure Decoder

///
/// An object that decodes the structure of a JS value.
///

private class JSStructureDecoder: Decoder {

    // MARK: Properties

    /// The decoder's storage.
    var container: JSCodingContainer

    /// The path to the current point in decoding.
    var codingPath: [CodingKey]

    /// Contextual user-provided information for use during decoding.
    var userInfo: [CodingUserInfoKey : Any]

    // MARK: Initilization

    init(container: JSCodingContainer, codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.container = container
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    // MARK: - Containers

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        fatalError("Unimplemented. WIP.")
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("Unimplemented. WIP.")
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {

        switch container {
        case .singleValue(let storage):
            return JSSingleValueDecodingContainer(storage: storage, codingPath: codingPath)

        default:
            let errorContext = DecodingError.Context(codingPath: codingPath, debugDescription: "Attempt to decode the result using a single value container, but the data is encoded as a \(container.debugType) container.")
            throw DecodingError.dataCorrupted(errorContext)
        }

    }

}

// MARK: - Single Value Decoder

private class JSSingleValueDecodingContainer: SingleValueDecodingContainer {

    // MARK: Properties

    /// The container's structure storage.
    var storage: SingleValueStorage

    /// The path to the current point in decoding.
    var codingPath: [CodingKey]

    // MARK: Initialization

    init(storage: SingleValueStorage, codingPath: [CodingKey]) {
        self.storage = storage
        self.codingPath = codingPath
    }

    // MARK: Decoding

    func decodeNil() -> Bool {

        switch storage {
        case .null:
            return true
        default:
            return false
        }

    }

    func decode(_ type: Bool.Type) throws -> Bool {

        switch storage {
        case .boolean(let bool):
            return bool
        default:
            try throwTypeError(expected: "Bool")
        }

    }

    func decode(_ type: Int.Type) throws -> Int {

        switch storage {
        case .integer(let integer):
            return integer.intValue
        default:
            try throwTypeError(expected: "Int")
        }

    }

    func decode(_ type: Int8.Type) throws -> Int8 {

        switch storage {
        case .integer(let integer):
            return try decodeInteger(integer)
        default:
            try throwTypeError(expected: "Int8")
        }

    }

    func decode(_ type: Int16.Type) throws -> Int16 {

        switch storage {
        case .integer(let integer):
            return try decodeInteger(integer)
        default:
            try throwTypeError(expected: "Int16")
        }

    }

    func decode(_ type: Int32.Type) throws -> Int32 {

        switch storage {
        case .integer(let integer):
            return try decodeInteger(integer)
        default:
            try throwTypeError(expected: "Int32")
        }

    }

    func decode(_ type: Int64.Type) throws -> Int64 {

        switch storage {
        case .integer(let integer):
            return try decodeInteger(integer)
        default:
            try throwTypeError(expected: "Int64")
        }

    }

    func decode(_ type: UInt.Type) throws -> UInt {

        switch storage {
        case .integer(let integer):
            return try decodeInteger(integer)
        default:
            try throwTypeError(expected: "UInt")
        }

    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {

        switch storage {
        case .integer(let integer):
            return try decodeInteger(integer)
        default:
            try throwTypeError(expected: "UInt8")
        }

    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {

        switch storage {
        case .integer(let integer):
            return try decodeInteger(integer)
        default:
            try throwTypeError(expected: "UInt16")
        }

    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {

        switch storage {
        case .integer(let integer):
            return try decodeInteger(integer)
        default:
            try throwTypeError(expected: "UInt32")
        }

    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {

        switch storage {
        case .integer(let integer):
            return try decodeInteger(integer)
        default:
            try throwTypeError(expected: "UInt64")
        }

    }

    func decode(_ type: Float.Type) throws -> Float {

        switch storage {
        case .float(let float):
            return float
        case .double(let double):
            return Float(double)
        default:
            try throwTypeError(expected: "Float")
        }

    }

    func decode(_ type: Double.Type) throws -> Double {

        switch storage {
        case .float(let float):
            return Double(float)
        case .double(let double):
            return double
        default:
            try throwTypeError(expected: "Float")
        }

    }

    func decode(_ type: String.Type) throws -> String {

        switch storage {
        case .string(let string):
            return string
        default:
            try throwTypeError(expected: "String")
        }

    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {

        if T.self == Date.self {

            switch storage {
            case .date(let date):
                return date as! T
            case .double(let timeInterval):
                return Date(timeIntervalSince1970: timeInterval / 1000) as! T
            case .float(let timeInterval):
                let timestamp = Double(timeInterval) / 1000
                return Date(timeIntervalSince1970: timestamp) as! T
            case .integer(let anyInterger):
                let timestamp = Double(anyInterger.intValue) / 1000
                return Date(timeIntervalSince1970: timestamp) as! T
            default:
                try throwTypeError(expected: "Date")
            }

        } else if T.self == URL.self {

            switch storage {
            case .string(let string):

                guard let url = URL(string: string) else {
                    try throwTypeError(expected: "URL")
                }

                return url as! T

            default:
                try throwTypeError(expected: "URL")
            }

        }

        let tempDecoder = JSStructureDecoder(container: .singleValue(storage), codingPath: codingPath)
        let decodedObject = try T(from: tempDecoder)

        return decodedObject

    }

    // MARK: Utilities

    /// Fails decoding because of an incompatible type.
    func throwTypeError(expected: String) throws -> Never {
        let type = storage.storedType
        let errorContext = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode `\(expected)` because value is of type `\(type)`.")
        throw DecodingError.typeMismatch(storage.storedType, errorContext)
    }

    /// Tries to decode a fixed width integer and reports an error on overflow.
    func decodeInteger<T: BinaryInteger & FixedWidthInteger>(_ integer: AnyInteger) throws -> T {

        guard let integer: T = integer.convertingType() else {
            throw DecodingError.dataCorruptedError(in: self, debugDescription: "Integer type `\(T.self)` is too small to store the bits of the decoded value.")
        }

        return integer

    }

}
