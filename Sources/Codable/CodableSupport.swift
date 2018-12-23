//
//  JavaScriptKit
//  Copyright (c) 2017 - present Alexis Aubry. Licensed under the MIT license.
//

import Foundation

/**
 * An encoding container.
 */

enum JSCodingContainer {

    /// A single value container associated with a single-value storage.
    case singleValue(SingleValueStorage)

    /// An unkeyed value container associated with a reference to an array storage.
    case unkeyed(ArrayStorage)

    /// A keyed value container associated with a reference to a dictionary storage.
    case keyed(DictionaryStorage)

}

// MARK: - Single Value Storage

/**
 * A storage container for JavaScript encoder/decoder.
 */

enum SingleValueStorage {

    /// A `null` value.
    case null

    /// A String value.
    case string(String)

    /// A Bool value.
    case boolean(Bool)

    /// A number value.
    case number(NSNumber)

    /// A date value.
    case date(Date)

    /// An empty object.
    case emptyObject

    /// The stored value.
    var storedValue: Any {
        switch self {
        case .null:
            return NSNull()
        case .string(let string):
            return string
        case .boolean(let bool):
            return bool
        case .number(let number):
            return number
        case .date(let date):
            return date
        case .emptyObject:
            return [String: Any]()
        }
    }

    /// The type of the stored value.
    var storedType: Any.Type {
        switch self {
        case .null: return NSNull.self
        case .string: return String.self
        case .boolean: return Bool.self
        case .number: return NSNumber.self
        case .date: return Date.self
        case .emptyObject: return Dictionary<String, Any>.self
        }
    }

    // MARK: Initialization

    /// Decodes the stored value.
    init(storedValue: Any) throws {
        if storedValue is NSNull {
            self = .null
        } else if storedValue is String {
            self = .string(storedValue as! String)
        } else if storedValue is Date {
            self = .date(storedValue as! Date)
        } else if storedValue is NSNumber {
            self = .number(storedValue as! NSNumber)
        } else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Could not decode \(storedValue) because its type is not supported. Supported types include null, booleans, strings, numbers and dates.")
            throw DecodingError.dataCorrupted(context)
        }
    }

}

// MARK: - Array Storage

/**
 * An object that holds a reference to an array. Use this class when you need an Array with
 * reference semantics.
 */

class ArrayStorage {

    /// The underlying array object.
    private var array: [Any]

    // MARK: Initialization

    /// Creates an empty array storage.
    init() {
        array = [Any]()
    }

    /// Creates an array storage by copying the contents of an existing array.
    init(_ array: NSArray) {
        self.array = array as! [Any]
    }

    // MARK: Array Interaction

    /// The number of elements in the Array.
    var count: Int {
        return array.count
    }

    /// Appends an element to the array.
    func append(_ element: Any) {
        array.append(element)
    }

    /// Get the value at the given index.
    subscript(index: Int) -> Any {
        get {
            return array[index]
        }
        set {
            array[index] = newValue
        }
    }

    // MARK: Contents

    /// An immutable reference to the contents of the array storage.
    var body: [Any] {
        return array
    }

}

// MARK: - Dictionary Storage

/**
 * An object that holds a reference to a dictionary. Use this class when you need a Dictionary with
 * reference semantics.
 */

class DictionaryStorage {

    /// The underlying dictionary.
    private var dictionary: [AnyHashable: Any]

    // MARK: Initialization

    /// Creates an empty dictionary storage.
    init() {
        dictionary = [AnyHashable: Any]()
    }

    /// Creates a dictionary storage by copying the contents of an existing dictionary.
    init(_ dictionary: NSDictionary) {
        self.dictionary = dictionary as! [AnyHashable: Any]
    }

    // MARK: Dictionary Interaction

    /// Access the value of the dictionary for the given key.
    subscript(key: String) -> Any? {
        get {
            return dictionary[key]
        }
        set {
            dictionary[key] = newValue
        }
    }

    // MARK: Contents

    /// An immutable reference to the contents of the dictionary storage.
    var body: [AnyHashable: Any] {
        return dictionary
    }

    /// The keys indexing the storage contents.
    var keys: Dictionary<AnyHashable, Any>.Keys {
        return dictionary.keys
    }

}

// MARK: - Escaping

extension String {

    /// Escapes the JavaScript special characters.
    internal var escapingSpecialCharacters: String {
        let controlCharactersRange = UnicodeScalar(0x08) ... UnicodeScalar(0x0d)
        let escapablePuntuation = "\u{0022}\u{0027}\u{005C}"

        var escapableCharacters = CharacterSet(charactersIn: controlCharactersRange)
        escapableCharacters.insert(charactersIn: escapablePuntuation)

        return unicodeScalars.reduce("") {
            current, scalar in
            let needsEscaping = escapableCharacters.contains(scalar)
            let nextSequence = needsEscaping ? "\\u{\(String(scalar.value, radix: 16))}" : String(scalar)
            return current + nextSequence
        }
    }

}

// MARK: - JSON Key

/// A key for JavaScript objects.
enum JSONKey: CodingKey {

    /// A string key.
    case string(String)

    /// An index key.
    case index(Int)

    /// A string key for the object's superclass.
    case `super`

    /// The text value of the key.
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

    /// The integer value of the key?
    var intValue: Int? {

        switch self {
        case .index(let index):
            return index
        default:
            return nil
        }

    }

    /// Creates a JSON key with an integer raw key.
    init(intValue: Int) {
        self = .index(intValue)
    }

    /// Creates a JSON key with a String raw key.
    init(stringValue: String) {
        self = .string(stringValue)
    }

}
