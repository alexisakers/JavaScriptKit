/**
 *  JavaScriptKit
 *  Copyright (c) 2017 Alexis Aubry. Licensed under the MIT license.
 */

import Foundation

///
/// `JSEncoder` generates the JavaScript representation of `Encodable` arguments.
///

final class JSArgumentEncoder {

    ///
    /// Encodes an argument for use in JavaScript function expressions.
    ///
    /// - parameter argument: The argument to encode to JS.
    /// - returns: The JavaScript text representing the value.
    ///

    internal func encode(_ argument: Encodable) throws -> String {

        let encoder = JSConcreteEncoder()

        //==== I- Encode value into an encoding container ====//

        // Date and URL Encodable implementations are not compatible with JavaScript.
        if argument is Date {
            var singleValueStorage = encoder.singleValueContainer()
            try singleValueStorage.encode(argument as! Date)

        } else if argument is URL {
            var singleValueStorage = encoder.singleValueContainer()
            try singleValueStorage.encode(argument as! URL)

        } else {
            try argument.encode(to: encoder)
        }

        //==== II- Get the encoded value and convert it to JavaScript ====//

        guard let topLevelContainer = encoder.container else {
            let errorContext = EncodingError.Context(codingPath: encoder.codingPath,
                                                     debugDescription: "Top-level argument did not encode any values.")
            throw EncodingError.invalidValue(argument, errorContext)
        }

        switch topLevelContainer {
        case .singleValue(let encodedValue):
            return jsEncodeSingleValue(encodedValue)

        case .unkeyed(let arrayRef):
            return try jsEncodeObject(arrayRef.array)

        case .keyed(let dictionaryRef):
            return try jsEncodeObject(dictionaryRef.dictionary)
        }

    }

    /// Encodes the content of a single-value container to a JavaScript literal.
    private func jsEncodeSingleValue(_ singleValue: JSSingleValue) -> String {

        switch singleValue {
        case .null:
            return "null"

        case .boolean(let bool):
            return String(bool)

        case .string(let string):
            return string

        case .integer(let integer):
            return integer.makeString()

        case .float(let float):
            return String(float)

        case .double(let double):
            return String(double)

        case .emptyObject:
            return "{}"
        }

    }

    /// Encodes the contents of an unkeyed or a keyed container into a JSON literal.
    private func jsEncodeObject<T: Sequence>(_ object: T) throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
        return String(data: jsonData, encoding: .utf8)!
    }

}

enum StringLiteralEscaping {
    case automatic
    case manual(Bool)
}

// MARK: - Concrete Encoder

private class JSConcreteEncoder: Encoder {

    /// The encoder's storage.
    var container: JSEncodingContainer?

    /// The path to the current point in encoding.
    var codingPath: [CodingKey]

    /// Contextual user-provided information for use during encoding.
    var userInfo: [CodingUserInfoKey : Any]

    /// The string literal escaping strategies.
    var stringLiteralEscaping: StringLiteralEscaping

    /// Indicates whether can encoder should escape the
    var canQuoteStringLiteral: Bool {
        return container == nil
    }

    /// Indicates whether string literals should be quoted.
    var shouldQuoteStringLiteral: Bool {

        switch stringLiteralEscaping {
        case .automatic:
            return canQuoteStringLiteral

        case .manual(let value):
            return value
        }

    }

    // MARK: Initialization

    init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:], stringEscaping: StringLiteralEscaping = .automatic) {
        self.container = nil
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.stringLiteralEscaping = stringEscaping
    }

    // MARK: Coding Path Operations

    /// Indicates whether encoding has failed at the current key path.
    var containsFailures: Bool {
        return !codingPath.isEmpty
    }

    ///
    /// Asserts that it is possible for the encoded value to request a new container.
    ///
    /// The value can only request one container. If the storage contains more containers than the
    /// encoder has coding keys, it means that the value is trying to request more than one container
    /// which is invalid.
    ///

    func assertCanRequestNewContainer() {

        guard self.container == nil else {
            let previousContainerType = self.container!.type
            preconditionFailure("Attempt to encode value with a new container when it has already been encoded with a \(previousContainerType) container.")
        }

        guard !containsFailures else {
            preconditionFailure("An error occured while encoding a value at coding path \(codingPath) and cannot be recovered.")
        }

    }

    ///
    /// Performs the given closure with the given key pushed onto the end of the current coding path.
    ///
    /// - parameter key: The key to push. May be nil for unkeyed containers.
    /// - parameter work: The work to perform with the key in the path.
    ///

    fileprivate func with<T>(pushedKey key: CodingKey, _ work: () throws -> T) rethrows -> T {
        self.codingPath.append(key)
        let ret: T = try work()
        codingPath.removeLast()
        return ret
    }

    // MARK: Encoder

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        assertCanRequestNewContainer()
        /*let storageDictionary = NSMutableDictionary()
        container = .keyed(storageDictionary)
        let keyedContainer = JSKeyedEncodingContainer<Key>(referencing: self, codingPath: codingPath, wrapping: storageDictionary)
        return KeyedEncodingContainer(keyedContainer)*/
        fatalError("Unimplemented. WIP.")
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        assertCanRequestNewContainer()
        let storageArray = ArrayRef()
        container = .unkeyed(storageArray)
        return JSUnkeyedEncodingContainer(referencing: self, codingPath: codingPath, wrapping: storageArray)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        assertCanRequestNewContainer()
        return self
    }

}

// MARK: - Single Value Container

extension JSConcreteEncoder: SingleValueEncodingContainer {

    ///
    /// Asserts that a single value can be encoded into the container (i.e. that no value has
    /// previously been encoded.
    ///

    func assertCanEncodeSingleValue() {

        switch container {
        case .singleValue(_)?:
            preconditionFailure("Attempt to encode multiple values in a single value container.")

        case .keyed(_)?, .unkeyed(_)?:
            preconditionFailure("Attempt to encode value with a new container when it has already been encoded with a \(container!.type) container.")

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
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
    }

    func encode(_ value: Int8) throws {
        assertCanEncodeSingleValue()
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
    }

    func encode(_ value: Int16) throws {
        assertCanEncodeSingleValue()
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
    }

    func encode(_ value: Int32) throws {
        assertCanEncodeSingleValue()
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
    }

    func encode(_ value: Int64) throws {
        assertCanEncodeSingleValue()
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
    }

    func encode(_ value: UInt) throws {
        assertCanEncodeSingleValue()
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
    }

    func encode(_ value: UInt8) throws {
        assertCanEncodeSingleValue()
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
    }

    func encode(_ value: UInt16) throws {
        assertCanEncodeSingleValue()
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
    }

    func encode(_ value: UInt32) throws {
        assertCanEncodeSingleValue()
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
    }

    func encode(_ value: UInt64) throws {
        assertCanEncodeSingleValue()
        let anyInteger = AnyInteger(value)
        container = .singleValue(.integer(anyInteger))
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

private class JSUnkeyedEncodingContainer: UnkeyedEncodingContainer {

    /// A reference to the encoder we're writing to.
    let encoder: JSConcreteEncoder

    /// A reference to the container we're writing to.
    let container: ArrayRef

    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey]

    // MARK: Initialization

    init(referencing encoder: JSConcreteEncoder, codingPath: [CodingKey], wrapping container: ArrayRef) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    // MARK: Coding Path

    ///
    /// Performs the given closure with the given key pushed onto the end of the current coding path.
    ///
    /// - parameter key: The key to push. May be nil for unkeyed containers.
    /// - parameter work: The work to perform with the key in the path.
    ///

    fileprivate func with<T>(pushedKey key: CodingKey, _ work: () throws -> T) rethrows -> T {
        codingPath.append(key)
        let ret: T = try work()
        codingPath.removeLast()
        return ret
    }

    // MARK: Encoding

    var count: Int {
        return container.count
    }

    func encodeNil() throws {
        container.append("null")
    }

    func encode(_ value: Bool) throws {
        container.append(value)
    }

    func encode(_ value: Int) throws {
        container.append(value)
    }

    func encode(_ value: Int8) throws {
        container.append(value)
    }

    func encode(_ value: Int16) throws {
        container.append(value)
    }

    func encode(_ value: Int32) throws {
        container.append(value)
    }

    func encode(_ value: Int64) throws {
        container.append(value)
    }

    func encode(_ value: UInt) throws {
        container.append(value)
    }

    func encode(_ value: UInt8) throws {
        container.append(value)
    }

    func encode(_ value: UInt16) throws {
        container.append(value)
    }

    func encode(_ value: UInt32) throws {
        container.append(value)
    }

    func encode(_ value: UInt64) throws {
        container.append(value)
    }

    func encode(_ value: Float) throws {
        container.appendSingleValue(encoder.parseFloat(value))
    }

    func encode(_ value: Double) throws {
        container.appendSingleValue(encoder.parseDouble(value))
    }

    func encode(_ value: String) throws {
        container.append(value)
    }

    func encode<T: Encodable>(_ value: T) throws  {

        try encoder.with(pushedKey: JSONKey.index(count)) {

            let newContainer = try self.encoder.parseValue(value)

            switch newContainer {
            case .keyed(let dictionaryRef):
                container.append(dictionaryRef.dictionary)
            case .singleValue(let value):
                container.append(value.underlyingValue)
            case .unkeyed(let arrayRef):
                container.append(arrayRef.array)
            }

        }

    }

    // MARK: References

    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
        /*let dictionary = DictionaryRef
        self.container.append(dictionary)
        let container = JSKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)*/
        fatalError("Unimplemented. WIP.")
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        /*let array = NSMutableArray()
        self.container.add(array)
        return JSUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)*/
        fatalError("Unimplemented. WIP.")
    }

    func superEncoder() -> Encoder {
        return JSReferencingEncoder(referencing: encoder, at: container.count, wrapping: container)
    }

}

// MARK: - Single
/*
private class JSKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K

    /// A reference to the encoder we're writing to.
    let encoder: JSConcreteEncoder

    /// A reference to the container we're writing to.
    let container: DictionaryRef

    /// The path of coding keys taken to get to this point in encoding.
    var codingPath: [CodingKey]

    // MARK: Initialization

    init(referencing encoder: JSConcreteEncoder, codingPath: [CodingKey], wrapping container: DictionaryRef) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    // MARK: Coding Path Operations

    ///
    /// Performs the given closure with the given key pushed onto the end of the current coding path.
    ///
    /// - parameter key: The key to push. May be nil for unkeyed containers.
    /// - parameter work: The work to perform with the key in the path.
    ///

    func with<T>(pushedKey key: CodingKey, _ work: () throws -> T) rethrows -> T {
        codingPath.append(key)
        let ret: T = try work()
        codingPath.removeLast()
        return ret
    }

    // MARK: Encoding

    func encodeNil(forKey key: K) throws {
        container[key.stringValue] = NSNull()
    }

    func encode(_ value: Bool, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: Int, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: Int8, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: Int16, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: Int32, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: Int64, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: UInt, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: UInt8, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: UInt16, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: UInt32, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: UInt64, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: Float, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: Double, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode(_ value: String, forKey key: K) throws {
        container[key.stringValue] = encoder.box(value)
    }

    func encode<T: Encodable>(_ value: T, forKey key: K) throws {

        try with(pushedKey: key) {
            self.container[key.stringValue] = try self.encoder.box(value)
        }

    }

    // MARK: References

    func nestedContainer<NestedKey: CodingKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> {
        let dictionary = DictionaryRef()
        self.container[key.stringValue] = dictionary
        let container = JSKeyedEncodingContainer<NestedKey>(referencing: encoder, codingPath: codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let array = NSMutableArray()
        container[key.stringValue] = array
        return JSUnkeyedEncodingContainer(referencing: encoder, codingPath: codingPath, wrapping: array)
    }

    func superEncoder() -> Encoder {
        return JSReferencingEncoder(referencing: encoder, at: JSONKey.super, wrapping: container)
    }

    func superEncoder(forKey key: K) -> Encoder {
        return JSReferencingEncoder(referencing: encoder, at: key, wrapping: container)
    }

}
*/
// MARK: - Wrappers

extension JSConcreteEncoder {

    func parseString(_ value: String) -> JSSingleValue {
        let escapedString = value.escapingSpecialCharacters

        if shouldQuoteStringLiteral {
            return .string("\"\(escapedString)\"")
        } else {
            return .string(escapedString)
        }
    }

    func parseFloat(_ float: Float) -> JSSingleValue {

        if float == Float.infinity {
            return .string("Number.POSITIVE_INFINITY")
        } else if float == -Float.infinity {
            return .string("Number.NEGATIVE_INFINITY")
        } else if float.isNaN {
            return .string("Number.NaN")
        }

        return .float(float)

    }

    func parseDouble(_ double: Double) -> JSSingleValue {

        if double == Double.infinity {
            return .string("Number.POSITIVE_INFINITY")
        } else if double == -Double.infinity {
            return .string("Number.NEGATIVE_INFINITY")
        } else if double.isNaN {
            return .string("Number.NaN")
        }

        return .double(double)

    }

    func parseDate(_ date: Date) -> JSSingleValue {
        let timestamp = Int(date.timeIntervalSince1970) * 1000
        return .string("new Date(\(timestamp))")
    }

    func parseValue<T: Encodable>(_ value: T) throws -> JSEncodingContainer {

        if T.self == Date.self {
            return .singleValue(parseDate(value as! Date))
        } else if T.self == URL.self {
            return .singleValue(parseString((value as! URL).absoluteString))
        }

        let tempEncoder = JSConcreteEncoder(stringEscaping: .manual(canQuoteStringLiteral))
        try value.encode(to: tempEncoder)

        switch tempEncoder.container {
        case .some:
            return tempEncoder.container!

        case nil:
            return .singleValue(.emptyObject)
        }

    }

}

// MARK: - Reference

fileprivate class JSReferencingEncoder: JSConcreteEncoder {

    enum Reference {
        case array(ArrayRef, Int)
        case dictionary(DictionaryRef, String)
    }

    // MARK: Properties

    /// The encoder we're referencing.
    fileprivate let encoder: JSConcreteEncoder

    /// The container reference itself.
    private let reference: Reference

    // MARK: Initialization

    /// Initializes `self` by referencing the given array container in the given encoder.
    fileprivate init(referencing encoder: JSConcreteEncoder, at index: Int, wrapping array: ArrayRef) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init(codingPath: encoder.codingPath)
        self.stringLiteralEscaping = .manual(false)
        codingPath.append(JSONKey.index(index))
    }

    /// Initializes `self` by referencing the given dictionary container in the given encoder.
    fileprivate init(referencing encoder: JSConcreteEncoder, at key: CodingKey, wrapping dictionary: DictionaryRef) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, key.stringValue)
        super.init(codingPath: encoder.codingPath)
        self.stringLiteralEscaping = .manual(false)
        self.codingPath.append(key)
    }

    // MARK: Coding Path Operations

    /// Indicates whether encoding has failed at the current key path.
    override var containsFailures: Bool {
        return !(codingPath.count == 1)
    }

    // MARK: Deinitialization

    // Finalizes `self` by writing the contents of our storage to the referenced encoder's storage.
    deinit {
        let value: Any

        switch container {
        case nil:
            value = [String: Any]()

        case .singleValue(let singleValue)?:
            value = singleValue.underlyingValue

        case .unkeyed(let arrayRef)?:
            value = arrayRef.array

        case .keyed(let dictionaryRef)?:
            value = dictionaryRef.dictionary
        }

        switch self.reference {
        case .array(let arrayRef, let index):
            arrayRef.insert(value, at: index)

        case .dictionary(let dictionaryRef, let key):
            dictionaryRef[key] = value
        }
    }

}

// MARK: - JSON Key

enum JSONKey: CodingKey {

    case string(String)
    case index(Int)
    case `super`

    var stringValue: String {

        switch self {
        case .string(let string):
            return string
        case .index(let index):
            return "Index \(index)"
        case .super:
            return "super"
        }

    }

    var intValue: Int? {

        switch self {
        case .string(_):
            return nil
        case .index(let index):
            return index
        case .super:
            return nil
        }

    }

    init?(intValue: Int) {
        self = .index(intValue)
    }

    init?(stringValue: String) {
        self = .string(stringValue)
    }

}

// MARK: - Escaping

extension String {

    /// Escapes the JavaScript special characters.
    internal var escapingSpecialCharacters: String {

        return self
            .replacingOccurrences(of: "\u{0008}", with: "\\b")
            .replacingOccurrences(of: "\u{0009}", with: "\\t")
            .replacingOccurrences(of: "\u{000A}", with: "\\n")
            .replacingOccurrences(of: "\u{000B}", with: "\\v")
            .replacingOccurrences(of: "\u{000C}", with: "\\f")
            .replacingOccurrences(of: "\u{000D}", with: "\\r")
            .replacingOccurrences(of: "\u{0022}", with: "\\\"")
            .replacingOccurrences(of: "\u{0027}", with: "\\'")
            .replacingOccurrences(of: "\u{005C}", with: "\\")

    }

}
