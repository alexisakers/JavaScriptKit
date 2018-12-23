//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation

/**
 * Generates the JavaScript representation of `Encodable` arguments.
 */

class JavaScriptEncoder {

    /**
     * Encodes an argument for use in JavaScript function expressions.
     * - parameter argument: The argument to encode to JavaScript.
     * - returns: The JavaScript literal representing the value.
     */

    func encode(_ argument: Encodable) throws -> String {
        let structureEncoder = JSStructureEncoder()

        /*** I- Encode the structure of the value ***/

        // Date and URL Encodable implementations are not compatible with JavaScript.
        if let date = argument as? Date {
            var singleValueStorage = structureEncoder.singleValueContainer()
            try singleValueStorage.encode(date)

        } else if let url = argument as? URL {
            var singleValueStorage = structureEncoder.singleValueContainer()
            try singleValueStorage.encode(url)

        } else {
            try argument.encode(to: structureEncoder)
        }

        /*** II- Get the encoded value and convert it to a JavaScript literal ***/

        guard let topLevelContainer = structureEncoder.container else {
            throw EncodingError.invalidValue(argument,
                                             EncodingError.Context(codingPath: structureEncoder.codingPath,
                                                                   debugDescription: "Top-level argument did not encode any values."))
        }

        switch topLevelContainer {
        case .singleValue(let storage):
            return encodeJSSingleValue(storage)

        case .unkeyed(let storage):
            return try encodeJSObject(storage.body)

        case .keyed(let storage):
            return try encodeJSObject(storage.body)
        }
    }

    // MARK: Helpers

    /// Encodes the content of a single-value container storage as a JavaScript literal.
    private func encodeJSSingleValue(_ storage: SingleValueStorage) -> String {
        switch storage {
        case .null:
            return "null"
        case .string(let string):
            return string
        case .boolean(let bool):
            return String(bool)
        case .number(let number):
            return number.stringValue
        case .date(let date):
            let timestamp = Int(date.timeIntervalSince1970) * 1000
            return "new Date(\(timestamp))"
        case .emptyObject:
            return "{}"
        }
    }

    /// Encodes the contents of an unkeyed or a keyed container storage as a JSON literal.
    private func encodeJSObject<T: Sequence>(_ object: T) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
        return String(data: jsonData, encoding: .utf8)!
    }

}

// MARK: - Structure Encoder

/**
 * A class that serializes the structure of arguments before JavaScript literal conversion.
 */

private class JSStructureEncoder: Encoder {

    /// The string literal quoting method.
    enum StringLiteralQuoting {
        /// The literal will be quoted if encoded inside a single value container (default).
        case automatic

        /// The literal will be quoted if the manual value is set to `true`.
        case manual(Bool)
    }

    // MARK: Properties

    /// The encoder's storage.
    var container: JSCodingContainer?

    /// The path to the current point in encoding.
    var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    var userInfo: [CodingUserInfoKey : Any]

    // MARK: Options

    /// The type of the container (for debug printing)
    var containerType: String {
        switch container {
        case .singleValue?:
            return "a single value"
        case .unkeyed?:
            return "an unkeyed"
        case .keyed?:
            return "a keyed"
        case nil:
            return "an invalid"
        }
    }

    /// The string literal quoting strategy.
    let stringLiteralQuoting: StringLiteralQuoting

    /// Indicates whether the encoder can quote string literals.
    var canQuoteStringLiteral: Bool {
        return container == nil
    }

    /// Indicates whether string literals should be quoted by the encoder.
    var shouldQuoteStringLiteral: Bool {
        switch stringLiteralQuoting {
        case .automatic:
            return canQuoteStringLiteral
        case .manual(let value):
            return value
        }
    }

    /**
     * Indicates whether it is possible to encoded dates as single values. This is only `true` if
     * we're in an empty single value container, as `NSDate` is not compatible with JSON serialization.
     */

    var canEncodeSingleDateValues: Bool {
        return container == nil
    }

    // MARK: Initialization

    init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:], stringQuoting: StringLiteralQuoting = .automatic) {
        self.container = nil
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.stringLiteralQuoting = stringQuoting
    }

    // MARK: Coding Path Operations

    /// Indicates whether encoding has failed at the current key path.
    var containsFailures: Bool {
        return !codingPath.isEmpty
    }

    /**
     * Asserts that it is possible for the encoded value to request a new container.
     *
     * The value can only request one container. If the storage contains more containers than the
     * encoder has coding keys, it means that the value is trying to request more than one container
     * which is invalid.
     */

    func assertCanRequestNewContainer() {
        guard self.container == nil else {
            preconditionFailure("Attempt to encode value with a new container when it has already been encoded with \(containerType) container.")
        }

        guard !containsFailures else {
            preconditionFailure("An error occured while encoding a value at coding path \(codingPath) and cannot be recovered.")
        }
    }

    /**
     * Performs the given closure with the specified key pushed onto the end of the current coding path.
     * - parameter key: The key to push. May be nil for unkeyed containers.
     * - parameter work: The work to perform with the key in the path.
     *
     * If the `work` fails, `key` will be left in the coding path, which indicates a failure and
     * prevents requesting new cont ainers.
     */

    fileprivate func with<T>(pushedKey key: CodingKey, _ work: () throws -> T) rethrows -> T {
        self.codingPath.append(key)
        let ret: T = try work()
        codingPath.removeLast()
        return ret
    }

    // MARK: Containers

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        assertCanRequestNewContainer()
        let storage = DictionaryStorage()
        container = .keyed(storage)
        let keyedContainer = JSKeyedEncodingContainer<Key>(referencing: self, codingPath: codingPath, wrapping: storage)
        return KeyedEncodingContainer(keyedContainer)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanRequestNewContainer()
        let storage = ArrayStorage()
        container = .unkeyed(storage)
        return JSUnkeyedEncodingContainer(referencing: self, codingPath: codingPath, wrapping: storage)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanRequestNewContainer()
        return self
    }

}

// MARK: - Single Value Container

extension JSStructureEncoder: SingleValueEncodingContainer {

    /**
     * Asserts that a single value can be encoded into the container (i.e. that no value has
     * previously been encoded.
     */

    func assertCanEncodeSingleValue() {
        switch container {
        case .singleValue?:
            preconditionFailure("Attempt to encode multiple values in a single value container.")
        case .keyed?, .unkeyed?:
            preconditionFailure("Attempt to encode value with a new container when it has already been encoded with \(containerType) container.")
        case nil:
            return
        }
    }

    func encodeNil() throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.null)
    }

    func encode(_ value: Bool) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.boolean(value))
    }

    func encode(_ value: Int) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: Int8) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: Int16) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: Int32) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: Int64) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: UInt) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: UInt8) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: UInt16) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: UInt32) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: UInt64) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(.number(value as NSNumber))
    }

    func encode(_ value: Float) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(parseFloat(value))
    }

    func encode(_ value: Double) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(parseDouble(value))
    }

    func encode(_ value: String) throws {
        assertCanEncodeSingleValue()
        container = .singleValue(parseString(value))
    }

    func encode<T: Encodable>(_ value: T) throws  {
        assertCanEncodeSingleValue()
        container = try parseValue(value)
    }

}

// MARK: - Unkeyed Container

/**
 * An array encoding container.
 */

private class JSUnkeyedEncodingContainer: UnkeyedEncodingContainer {

    /// A reference to the encoder we're writing to.
    let encoder: JSStructureEncoder

    /// A reference to the container storage we're writing to.
    let storage: ArrayStorage

    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey]

    // MARK: Initialization

    init(referencing encoder: JSStructureEncoder, codingPath: [CodingKey], wrapping storage: ArrayStorage) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.storage = storage
    }

    // MARK: Encoding

    var count: Int {
        return storage.count
    }

    func encodeNil() throws {
        storage.append("null")
    }

    func encode(_ value: Bool) throws {
        storage.append(value)
    }

    func encode(_ value: Int) throws {
        storage.append(value)
    }

    func encode(_ value: Int8) throws {
        storage.append(value)
    }

    func encode(_ value: Int16) throws {
        storage.append(value)
    }

    func encode(_ value: Int32) throws {
        storage.append(value)
    }

    func encode(_ value: Int64) throws {
        storage.append(value)
    }

    func encode(_ value: UInt) throws {
        storage.append(value)
    }

    func encode(_ value: UInt8) throws {
        storage.append(value)
    }

    func encode(_ value: UInt16) throws {
        storage.append(value)
    }

    func encode(_ value: UInt32) throws {
        storage.append(value)
    }

    func encode(_ value: UInt64) throws {
        storage.append(value)
    }

    func encode(_ value: Float) throws {
        storage.append(encoder.parseFloat(value).storedValue)
    }

    func encode(_ value: Double) throws {
        storage.append(encoder.parseDouble(value).storedValue)
    }

    func encode(_ value: String) throws {
        storage.append(value)
    }

    func encode<T: Encodable>(_ value: T) throws  {
        try encoder.with(pushedKey: JSONKey.index(count)) {
            let newContainer = try self.encoder.parseValue(value)

            switch newContainer {
            case .singleValue(let value):
                storage.append(value.storedValue)
            case .unkeyed(let arrayStorage):
                storage.append(arrayStorage.body)
            case .keyed(let dictionaryStorage):
                storage.append(dictionaryStorage.body)
            }
        }
    }

    // MARK: Nested Containers

    /// The nested unkeyed containers referencing this container.
    var nestedUnkeyedContainers: [Int: ArrayStorage] = [:]

    /// The nested keyed containers referencing this container.
    var nestedKeyedContainers: [Int: DictionaryStorage] = [:]

    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {

        let containerIndex = storage.count
        let nestedStorage = DictionaryStorage()

        storage.append(nestedStorage)
        nestedKeyedContainers[containerIndex] = nestedStorage

        let keyedContainer = JSKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: nestedStorage)
        return KeyedEncodingContainer(keyedContainer)

    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let containerIndex = storage.count
        let nestedStorage = ArrayStorage()

        storage.append(nestedStorage)
        nestedUnkeyedContainers[containerIndex] = nestedStorage

        return JSUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: nestedStorage)
    }

    func superEncoder() -> Encoder {
        let lastIndex = storage.count
        storage.append(())
        return JSReferencingEncoder(referencing: encoder, at: lastIndex, wrapping: storage)
    }

    // MARK: Deinitialization

    // Insert the contents of the nested containers into the array storage.
    deinit {
        for (index, unkeyedContainerStorage) in nestedUnkeyedContainers {
            storage[index] = unkeyedContainerStorage.body
        }

        for (key, keyedContainerStorage) in nestedKeyedContainers {
            storage[key] = keyedContainerStorage.body
        }
    }

}

// MARK: - Keyed Encoding Container

/**
 * An keyed encoding container for object.
 */

private class JSKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K

    /// A reference to the encoder we're writing to.
    let encoder: JSStructureEncoder

    /// A reference to the container storage we're writing to.
    let storage: DictionaryStorage

    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey]

    // MARK: Initialization

    init(referencing encoder: JSStructureEncoder, codingPath: [CodingKey], wrapping storage: DictionaryStorage) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.storage = storage
    }

    // MARK: Encoding

    func encodeNil(forKey key: K) throws {
        storage[key.stringValue] = NSNull()
    }

    func encode(_ value: Bool, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: Int, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: Int8, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: Int16, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: Int32, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: Int64, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: UInt, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: UInt8, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: UInt16, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: UInt32, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: UInt64, forKey key: K) throws {
        storage[key.stringValue] = value
    }

    func encode(_ value: Float, forKey key: K) throws {
        storage[key.stringValue] = encoder.parseFloat(value).storedValue
    }

    func encode(_ value: Double, forKey key: K) throws {
        storage[key.stringValue] = encoder.parseDouble(value).storedValue
    }

    func encode(_ value: String, forKey key: K) throws {
        storage[key.stringValue] = encoder.parseString(value).storedValue
    }

    func encode<T: Encodable>(_ value: T, forKey key: K) throws {
        try encoder.with(pushedKey: JSONKey.string(key.stringValue)) {
            let newContainer = try self.encoder.parseValue(value)

            switch newContainer {
            case .keyed(let storage):
                storage[key.stringValue] = storage.body
            case .singleValue(let value):
                storage[key.stringValue] = value.storedValue
            case .unkeyed(let storage):
                storage.append(storage.body)
            }
        }
    }

    // MARK: Nested Containers

    var nestedUnkeyedContainers: [String: ArrayStorage] = [:]
    var nestedKeyedContainers: [String: DictionaryStorage] = [:]

    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = DictionaryStorage()
        storage[key.stringValue] = dictionary
        nestedKeyedContainers[key.stringValue] = dictionary
        let container = JSKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let array = ArrayStorage()
        storage[key.stringValue] = array
        nestedUnkeyedContainers[key.stringValue] = array
        return JSUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }

    func superEncoder() -> Encoder {
        return JSReferencingEncoder(referencing: encoder, at: JSONKey.super, wrapping: storage)
    }

    func superEncoder(forKey key: K) -> Encoder {
        return JSReferencingEncoder(referencing: encoder, at: key, wrapping: storage)
    }

    // MARK: Deinitialization

    // Insert the contents of the nested containers into the dictionary storage.
    deinit {
        for (key, unkeyedContainerStorage) in nestedUnkeyedContainers {
            storage[key] = unkeyedContainerStorage.body
        }

        for (key, keyedContainerStorage) in nestedKeyedContainers {
            storage[key] = keyedContainerStorage.body
        }
    }

}

// MARK: - Parsers

extension JSStructureEncoder {

    /// Escapes and quotes a String if required, and returns it inside a Single Value container.
    func parseString(_ value: String) -> SingleValueStorage {
        let escapedString = value.escapingSpecialCharacters
        return shouldQuoteStringLiteral ? .string("\"\(escapedString)\"") : .string(escapedString)
    }

    /// Returns the correct representation of the Float for JavaScript.
    func parseFloat(_ value: Float) -> SingleValueStorage {
        if value == Float.infinity {
            return .string("Number.POSITIVE_INFINITY")
        } else if value == -Float.infinity {
            return .string("Number.NEGATIVE_INFINITY")
        } else if value.isNaN {
            return .string("Number.NaN")
        }

        return .number(value as NSNumber)
    }

    /// Returns the correct representation of the Double for JavaScript.
    func parseDouble(_ value: Double) -> SingleValueStorage {
        if value == Double.infinity {
            return .string("Number.POSITIVE_INFINITY")
        } else if value == -Double.infinity {
            return .string("Number.NEGATIVE_INFINITY")
        } else if value.isNaN {
            return .string("Number.NaN")
        }

        return .number(value as NSNumber)
    }

    /// Encodes the value and returns the container it has been encoded to.
    func parseValue<T: Encodable>(_ value: T) throws -> JSCodingContainer {
        if let date = value as? Date {
            if canEncodeSingleDateValues {
                return .singleValue(.date(date))
            }

            let timestamp = Int(date.timeIntervalSince1970) * 1000
            return .singleValue(.number(timestamp as NSNumber))

        } else if let url = value as? URL {
            return .singleValue(parseString(url.absoluteString))
        }

        let tempEncoder = JSStructureEncoder(stringQuoting: .manual(canQuoteStringLiteral))
        try value.encode(to: tempEncoder)

        return tempEncoder.container ?? .singleValue(.emptyObject)
    }

}

// MARK: - Reference

/**
 * A structure encoder that references the contents of a sub-encoder.
 */

private class JSReferencingEncoder: JSStructureEncoder {

    /// The kind of refrence.
    enum Reference {
        /// The encoder references an array at the given index.
        case array(ArrayStorage, Int)

        /// The encoder references a dictionary at the given key.
        case dictionary(DictionaryStorage, String)
    }

    // MARK: Properties

    /// The encoder we're referencing.
    let encoder: JSStructureEncoder

    /// The container reference itself.
    let reference: Reference

    // MARK: Initialization

    /// Initializes `self` by referencing the given array container in the given encoder.
    fileprivate init(referencing encoder: JSStructureEncoder, at index: Int, wrapping array: ArrayStorage) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init(codingPath: encoder.codingPath, stringQuoting: .manual(false))
        codingPath.append(JSONKey.index(index))
    }

    /// Initializes `self` by referencing the given dictionary container in the given encoder.
    fileprivate init(referencing encoder: JSStructureEncoder, at key: CodingKey, wrapping dictionary: DictionaryStorage) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, key.stringValue)
        super.init(codingPath: encoder.codingPath, stringQuoting: .manual(false))
        self.codingPath.append(key)
    }

    // MARK: Options

    override var containsFailures: Bool {
        return codingPath.count != (encoder.codingPath.count + 1)
    }

    override var canEncodeSingleDateValues: Bool {
        return false
    }

    // MARK: Deinitialization

    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let value: Any

        switch container {
        case nil:
            value = [String: Any]()

        case .singleValue(let storage)?:
            value = storage.storedValue

        case .unkeyed(let storage)?:
            value = storage.body

        case .keyed(let storage)?:
            value = storage.body
        }

        switch reference {
        case .array(let remoteStorage, let index):
            remoteStorage[index] = value

        case .dictionary(let remoteStorage, let key):
            remoteStorage[key] = value
        }
    }

}
