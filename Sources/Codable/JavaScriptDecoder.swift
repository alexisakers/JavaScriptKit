//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation

/**
 * Decodes a JavaScript expression result to a `Decodable` value.
 */

final class JavaScriptDecoder {

    /**
     * Decodes a value returned by a JavaScript expression and decodes it as a the specified
     * `Decodable` type.
     *
     * - parameter value: The value returned by the JavaScript expression.
     * - returns: The JavaScript text representing the value.
     */

    func decode<T: Decodable>(_ value: Any) throws -> T {
        let container = try JavaScriptDecoder.makeContainer(with: value)
        let decoder = JSStructureDecoder(container: container)

        // Date and URL Decodable implementations are not compatible with JavaScript.
        if T.self == URL.self || T.self == Date.self {
            let singleValueContainer = try decoder.singleValueContainer()
            return try singleValueContainer.decode(T.self)
        }

        return try T(from: decoder)
    }

    /// Creates a Coding Container from a value.
    fileprivate static func makeContainer(with value: Any) throws -> JSCodingContainer {
        if let dictionary = value as? NSDictionary {
            let storage = DictionaryStorage(dictionary)
            return .keyed(storage)
        } else if let array = value as? NSArray {
            let storage = ArrayStorage(array)
            return .unkeyed(storage)
        } else {
            let storage = try SingleValueStorage(storedValue: value)
            return .singleValue(storage)
        }
    }
    
}

// MARK: - Structure Decoder

/**
 * An object that decodes the structure of a JavaScript value.
 */

private class JSStructureDecoder: Decoder {

    // MARK: Properties

    /// The decoder's storage.
    var container: JSCodingContainer

    /// The path to the current point in decoding.
    var codingPath: [CodingKey]

    /// Contextual user-provided information for use during decoding.
    var userInfo: [CodingUserInfoKey : Any]

    /// The type of the container (for debug printing)
    var containerType: String {
        switch container {
        case .singleValue:
            return "a single value"
        case .unkeyed:
            return "an unkeyed"
        case .keyed:
            return "a keyed"
        }
    }

    // MARK: Initilization

    init(container: JSCodingContainer, codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey: Any] = [:]) {
        self.container = container
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    // MARK: - Containers

    func container<Key: CodingKey>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> {
        switch container {
        case .keyed(let storage):
            let decodingContainer = JSKeyedDecodingContainer<Key>(referencing: self, storage: storage)
            return KeyedDecodingContainer(decodingContainer)

        default:
            let errorContext = DecodingError.Context(codingPath: codingPath, debugDescription: "Attempt to decode the result using a keyed container container, but the data is encoded as \(containerType) container.")
            throw DecodingError.dataCorrupted(errorContext)
        }
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        switch container {
        case .unkeyed(let storage):
            return JSUnkeyedDecodingContainer(referencing: self, storage: storage)

        default:
            let errorContext = DecodingError.Context(codingPath: codingPath, debugDescription: "Attempt to decode the result using an unkeyed container container, but the data is encoded as \(containerType) container.")
            throw DecodingError.dataCorrupted(errorContext)
        }
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        switch container {
        case .singleValue(let storage):
            return JSSingleValueDecodingContainer(referencing: self, storage: storage, codingPath: codingPath)

        default:
            let errorContext = DecodingError.Context(codingPath: codingPath, debugDescription: "Attempt to decode the result using a single value container, but the data is encoded as \(containerType) container.")
            throw DecodingError.dataCorrupted(errorContext)
        }
    }

}

// MARK: - Single Value Decoder

/**
 * A decoding container for a single value.
 */

private class JSSingleValueDecodingContainer: SingleValueDecodingContainer {

    // MARK: Properties

    /// The reference to the decoder we're reading from.
    let decoder: JSStructureDecoder

    /// The container's structure storage.
    let storage: SingleValueStorage

    /// The path to the current point in decoding.
    var codingPath: [CodingKey]

    // MARK: Initialization

    init(referencing decoder: JSStructureDecoder, storage: SingleValueStorage, codingPath: [CodingKey]) {
        self.decoder = decoder
        self.storage = storage
        self.codingPath = codingPath
    }

    // MARK: Decoding

    func decodeNil() -> Bool {
        return decoder.unboxNil(storage)
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return try decoder.unboxBool(storage)
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try decoder.unboxInt(storage)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try decoder.unboxInt8(storage)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try decoder.unboxInt16(storage)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try decoder.unboxInt32(storage)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try decoder.unboxInt64(storage)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        return try decoder.unboxUInt(storage)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decoder.unboxUInt8(storage)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decoder.unboxUInt16(storage)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decoder.unboxUInt32(storage)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decoder.unboxUInt64(storage)
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try decoder.unboxFloat(storage)
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try decoder.unboxDouble(storage)
    }

    func decode(_ type: String.Type) throws -> String {
        return try decoder.unboxString(storage)
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        return try decoder.unboxDecodable(storage)
    }

}

// MARK: - Unkeyed Container

/**
 * A decoding container for unkeyed storage.
 */

private class JSUnkeyedDecodingContainer: UnkeyedDecodingContainer {

    // MARK: Properties

    /// The reference to the parent decoder.
    let decoder: JSStructureDecoder

    /// The array storage we're decoding.
    let storage: ArrayStorage

    // MARK: Unkeyed Container

    /// The path to the current point in decoding.
    var codingPath: [CodingKey]

    /// The number of elements in the container.
    var count: Int? {
        return storage.count
    }

    /// Whether the container has finished decoding elements.
    var isAtEnd: Bool {
        return storage.count == currentIndex
    }

    /// The current index in the container.
    var currentIndex: Int = 0

    // MARK: Initialization

    init(referencing decoder: JSStructureDecoder, storage: ArrayStorage, codingPath: [CodingKey] = []) {
        self.decoder = decoder
        self.storage = storage
        self.codingPath = codingPath
    }

    // MARK: Decoding

    /// Get the value at the current index, converted to the specified type.
    func getNextValue<T>() throws -> T {
        guard !isAtEnd else {
            throw DecodingError.valueNotFound(Decoder.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get value: unkeyed container is at end."))
        }

        guard let value = self.storage[currentIndex] as? T else {
            throw DecodingError.valueNotFound(Decoder.self,
                                              DecodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Cannot get value: unexpected type."))
        }

        currentIndex += 1
        return value
    }

    /// Decode the value at the current index.
    func decodeAtCurrentIndex<T>(_ unboxer: (SingleValueStorage) throws -> T) throws -> T {
        let valueStorage = try SingleValueStorage(storedValue: getNextValue())
        return try unboxer(valueStorage)
    }

    func decodeNil() throws -> Bool {
        return try decodeAtCurrentIndex(decoder.unboxNil)
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return try decodeAtCurrentIndex(decoder.unboxBool)
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try decodeAtCurrentIndex(decoder.unboxInt)
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try decodeAtCurrentIndex(decoder.unboxInt8)
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try decodeAtCurrentIndex(decoder.unboxInt16)
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try decodeAtCurrentIndex(decoder.unboxInt32)
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try decodeAtCurrentIndex(decoder.unboxInt64)
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        return try decodeAtCurrentIndex(decoder.unboxUInt)
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try decodeAtCurrentIndex(decoder.unboxUInt8)
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try decodeAtCurrentIndex(decoder.unboxUInt16)
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try decodeAtCurrentIndex(decoder.unboxUInt32)
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try decodeAtCurrentIndex(decoder.unboxUInt64)
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try decodeAtCurrentIndex(decoder.unboxFloat)
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try decodeAtCurrentIndex(decoder.unboxDouble)
    }

    func decode(_ type: String.Type) throws -> String {
        return try decodeAtCurrentIndex(decoder.unboxString)
    }

    func decode<T: Decodable>(_ type: T.Type) throws -> T {
        guard !self.isAtEnd else { throw indexArrayOutOfBounds }

        let value = storage[currentIndex]
        currentIndex += 1

        return try decoder.unboxDecodableValue(value)
    }

    // MARK: Nested Containers

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let dictionaryStorage = try DictionaryStorage(getNextValue())
        let decodingContainer = JSKeyedDecodingContainer<NestedKey>(referencing: decoder,
                                                                    storage: dictionaryStorage,
                                                                    codingPath: codingPath)

        return KeyedDecodingContainer(decodingContainer)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let arrayStorage = try ArrayStorage(getNextValue())
        return JSUnkeyedDecodingContainer(referencing: decoder, storage: arrayStorage, codingPath: codingPath)
    }

    func superDecoder() throws -> Decoder {
        let container = try JavaScriptDecoder.makeContainer(with: getNextValue())
        return JSStructureDecoder(container: container, codingPath: decoder.codingPath, userInfo: decoder.userInfo)
    }

    // MARK: Error

    /// The error to throw when
    var indexArrayOutOfBounds: Error {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Index array out of bounds \(currentIndex)")
        return DecodingError.dataCorrupted(context)
    }

}

// MARK: - Keyed Container

/**
 * A decoding container for keyed storage.
 */

private class JSKeyedDecodingContainer<K: CodingKey>: KeyedDecodingContainerProtocol {
    typealias Key = K

    // MARK: Properties

    /// The reference to the parent decoder.
    let decoder: JSStructureDecoder

    /// The array storage we're decoding.
    let storage: DictionaryStorage

    // MARK: Keyed Container

    /// The path to the current point in decoding.
    var codingPath: [CodingKey]

    /// All the keys known by the decoder.
    let allKeys: [K]

    // MARK: Initialization

    init(referencing decoder: JSStructureDecoder, storage: DictionaryStorage, codingPath: [CodingKey] = []) {
        allKeys = storage.keys.compactMap { K(stringValue: "\($0.base)") }

        self.decoder = decoder
        self.storage = storage
        self.codingPath = codingPath
    }

    // MARK: Decoding

    /// Decode the value for the given key.
    func decodeValue<T>(forKey key: Key, _ unboxer: (SingleValueStorage) throws -> T) throws -> T {
        guard let value = storage[key.stringValue] else {
            throw DecodingError.valueNotFound(T.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Value for key \(key) not found."))
        }

        let valueStorage = try SingleValueStorage(storedValue: value)
        return try unboxer(valueStorage)
    }

    func contains(_ key: K) -> Bool {
        return allKeys.contains(where: { $0.stringValue == key.stringValue })
    }

    func decodeNil(forKey key: K) throws -> Bool {
        return storage[key.stringValue] == nil
    }

    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        return try decodeValue(forKey: key, decoder.unboxBool)
    }

    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        return try decodeValue(forKey: key, decoder.unboxInt)
    }

    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        return try decodeValue(forKey: key, decoder.unboxInt8)
    }

    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        return try decodeValue(forKey: key, decoder.unboxInt16)
    }

    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        return try decodeValue(forKey: key, decoder.unboxInt32)
    }

    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        return try decodeValue(forKey: key, decoder.unboxInt64)
    }

    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        return try decodeValue(forKey: key, decoder.unboxUInt)
    }

    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        return try decodeValue(forKey: key, decoder.unboxUInt8)
    }

    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        return try decodeValue(forKey: key, decoder.unboxUInt16)
    }

    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        return try decodeValue(forKey: key, decoder.unboxUInt32)
    }

    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        return try decodeValue(forKey: key, decoder.unboxUInt64)
    }

    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        return try decodeValue(forKey: key, decoder.unboxFloat)
    }

    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        return try decodeValue(forKey: key, decoder.unboxDouble)
    }

    func decode(_ type: String.Type, forKey key: K) throws -> String {
        return try decodeValue(forKey: key, decoder.unboxString)
    }

    func decode<T: Decodable>(_ type: T.Type, forKey key: K) throws -> T {
        guard let value = storage[key.stringValue] else {
            throw DecodingError.valueNotFound(T.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Value for key \(key) not found."))
        }

        return try decoder.unboxDecodableValue(value)
    }

    // MARK: Nested Containers

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: K) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        guard let value = storage[key.stringValue] as? NSDictionary else {
            throw DecodingError.valueNotFound(NSDictionary.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Could not find a nested keyed container for key \(key)."))
        }

        let dictionaryStorage = DictionaryStorage(value)
        let decodingContainer = JSKeyedDecodingContainer<NestedKey>(referencing: decoder, storage: dictionaryStorage, codingPath: codingPath)

        return KeyedDecodingContainer(decodingContainer)
    }

    func nestedUnkeyedContainer(forKey key: K) throws -> UnkeyedDecodingContainer {
        guard let value = storage[key.stringValue] as? NSArray else {
            throw DecodingError.valueNotFound(NSArray.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Could not find a nested unkeyed container for key \(key)."))
        }

        let arrayStorage = ArrayStorage(value)
        return JSUnkeyedDecodingContainer(referencing: decoder, storage: arrayStorage, codingPath: codingPath)
    }

    func superDecoder() throws -> Decoder {
        guard let value = storage[JSONKey.super.stringValue] else {
            throw DecodingError.valueNotFound(NSDictionary.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Could not find a super decoder for key super."))
        }

        let container = try JavaScriptDecoder.makeContainer(with: value)
        return JSStructureDecoder(container: container, codingPath: decoder.codingPath, userInfo: decoder.userInfo)
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        guard let value = storage[key.stringValue] else {
            throw DecodingError.valueNotFound(NSDictionary.self,
                                              DecodingError.Context(codingPath: codingPath,
                                                                    debugDescription: "Could not find a super decoder for key \(key)."))
        }

        let container = try JavaScriptDecoder.makeContainer(with: value)
        return JSStructureDecoder(container: container, codingPath: decoder.codingPath, userInfo: decoder.userInfo)
    }

}

// MARK: - Unboxing

extension JSStructureDecoder {

    func unboxNil(_ storage: SingleValueStorage) -> Bool {
        switch storage {
        case .null:
            return true
        default:
            return false
        }
    }

    func unboxBool(_ storage: SingleValueStorage) throws -> Bool {
        switch storage {
        case .boolean(let bool):
            return bool

        case .number(let number):
            guard (number == kCFBooleanTrue) || (number == kCFBooleanFalse) else {
                try throwTypeError(storedType: storage.storedType, expected: "Bool")
            }

            return number.boolValue

        default:
            try throwTypeError(storedType: storage.storedType, expected: "Bool")
        }
    }

    func unboxInt(_ storage: SingleValueStorage) throws -> Int {
        switch storage {
        case .number(let number):
            return number.intValue
        default:
            try throwTypeError(storedType: storage.storedType, expected: "Int")
        }
    }

    func unboxInt8(_ storage: SingleValueStorage) throws -> Int8 {
        switch storage {
        case .number(let number):
            return number.int8Value
        default:
            try throwTypeError(storedType: storage.storedType, expected: "Int8")
        }
    }

    func unboxInt16(_ storage: SingleValueStorage) throws -> Int16 {
        switch storage {
        case .number(let number):
            return number.int16Value
        default:
            try throwTypeError(storedType: storage.storedType, expected: "Int16")
        }
    }

    func unboxInt32(_ storage: SingleValueStorage) throws -> Int32 {
        switch storage {
        case .number(let number):
            return number.int32Value
        default:
            try throwTypeError(storedType: storage.storedType, expected: "Int32")
        }
    }

    func unboxInt64(_ storage: SingleValueStorage) throws -> Int64 {
        switch storage {
        case .number(let number):
            return number.int64Value
        default:
            try throwTypeError(storedType: storage.storedType, expected: "Int64")
        }
    }

    func unboxUInt(_ storage: SingleValueStorage) throws -> UInt {
        switch storage {
        case .number(let number):
            return number.uintValue
        default:
            try throwTypeError(storedType: storage.storedType, expected: "UInt")
        }
    }

    func unboxUInt8(_ storage: SingleValueStorage) throws -> UInt8 {
        switch storage {
        case .number(let number):
            return number.uint8Value
        default:
            try throwTypeError(storedType: storage.storedType, expected: "UInt8")
        }
    }

    func unboxUInt16(_ storage: SingleValueStorage) throws -> UInt16 {
        switch storage {
        case .number(let number):
            return number.uint16Value
        default:
            try throwTypeError(storedType: storage.storedType, expected: "UInt16")
        }
    }

    func unboxUInt32(_ storage: SingleValueStorage) throws -> UInt32 {
        switch storage {
        case .number(let number):
            return number.uint32Value
        default:
            try throwTypeError(storedType: storage.storedType, expected: "UInt32")
        }
    }

    func unboxUInt64(_ storage: SingleValueStorage) throws -> UInt64 {
        switch storage {
        case .number(let number):
            return number.uint64Value
        default:
            try throwTypeError(storedType: storage.storedType, expected: "UInt64")
        }
    }

    func unboxFloat(_ storage: SingleValueStorage) throws -> Float {
        switch storage {
        case .number(let number):
            return Float(number.doubleValue)
        default:
            try throwTypeError(storedType: storage.storedType, expected: "Float")
        }
    }

    func unboxDouble(_ storage: SingleValueStorage) throws -> Double {
        switch storage {
        case .number(let number):
            return number.doubleValue
        default:
            try throwTypeError(storedType: storage.storedType, expected: "Float")
        }
    }

    func unboxString(_ storage: SingleValueStorage) throws -> String {
        switch storage {
        case .string(let string):
            return string
        default:
            try throwTypeError(storedType: storage.storedType, expected: "String")
        }
    }

    func unboxDate(_ storage: SingleValueStorage) throws -> Date {
        switch storage {
        case .date(let date):
            return date
        case .number(let number):
            return Date(timeIntervalSince1970: number.doubleValue / 1000)
        default:
            try throwTypeError(storedType: storage.storedType, expected: "Date")
        }
    }

    func unboxURL(_ storage: SingleValueStorage) throws -> URL {
        switch storage {
        case .string(let string):
            guard let url = URL(string: string) else {
                try throwTypeError(storedType: storage.storedType, expected: "URL")
            }

            return url

        default:
            try throwTypeError(storedType: storage.storedType, expected: "URL")
        }
    }

    func unboxDecodableValue<T: Decodable>(_ value: Any) throws -> T {
        let container = try JavaScriptDecoder.makeContainer(with: value)
        return try unboxDecodable(in: container)
    }

    func unboxDecodable<T: Decodable>(_ storage: SingleValueStorage) throws -> T {
        if T.self == Date.self {
            return try unboxDate(storage) as! T
        } else if T.self == URL.self {
            return try unboxURL(storage) as! T
        }

        return try unboxDecodable(in: .singleValue(storage))
    }

    private func unboxDecodable<T: Decodable>(in container: JSCodingContainer) throws -> T {
        let tempDecoder = JSStructureDecoder(container: container, codingPath: codingPath)
        let decodedObject = try T(from: tempDecoder)

        return decodedObject
    }

    // MARK: Utilities

    /// Fails decoding because of an incompatible type.
    func throwTypeError(storedType: Any.Type, expected: String) throws -> Never {
        let errorContext = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode `\(expected)` because value is of type `\(storedType)`.")
        throw DecodingError.typeMismatch(storedType, errorContext)
    }

}
