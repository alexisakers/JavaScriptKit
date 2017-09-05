import Foundation

///
/// An encoding container.
///

enum JSCodingContainer {

    /// A single value container associated with a single-value storage.
    case singleValue(SingleValueStorage)

    /// An unkeyed value container associated with a reference to an array storage.
    case unkeyed(ArrayStorage)

    /// A keyed value container associated with a reference to a dictionary storage.
    case keyed(DictionaryStorage)

    /// The type of the container (for debug printing)
    var debugType: String {

        switch self {
        case .singleValue(_):
            return "single value"
        case .unkeyed(_):
            return "unkeyed"
        case .keyed(_):
            return "keyed"
        }

    }

}

// MARK: - Single Value Storage

///
/// A storage container for JavaScript encoder/decoder.
///

enum SingleValueStorage {

    /// A `null` value.
    case null

    /// A Boolean value.
    case boolean(Bool)

    /// A String value.
    case string(String)

    /// An integer value.
    case integer(AnyInteger)

    /// A Float value.
    case float(Float)

    /// A Double value.
    case double(Double)

    /// A Date value.
    case date(Date)

    /// An empty object.
    case emptyObject

    /// The stored value.
    var storedValue: Any {

        switch self {
        case .null:
            return NSNull()
        case .boolean(let bool):
            return bool
        case .string(let string):
            return string
        case .integer(let integer):
            return integer.intValue
        case .float(let float):
            return float
        case .double(let double):
            return double
        case .date(let date):
            return date
        case .emptyObject:
            return [String: Any]()
        }

    }

    /// The type of the stored value.
    var storedType: Any.Type {
        return type(of: storedValue)
    }

}

// MARK: - Array Storage

///
/// An object that holds a reference to an array. Use this class when you need an Array with
/// reference semantics.
///

class ArrayStorage {

    /// The underlying object.
    var array: [Any]

    // MARK: Initialization

    /// Creates an empty array storage.
    init() {
        array = [Any]()
    }

    /// Creates an array from an existing copy.
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

    /// Inserts an element in the array at the given index.
    func insert(_ value: Any, at index: Int) {
        array.insert(value, at: index)
    }

}

// MARK: - Dictionary Storage

///
/// An object that holds a reference to a dictionary. Use this class when you need a Dictionary with
/// reference semantics.
///

class DictionaryStorage {

    /// The underlying dictionary.
    var dictionary: [AnyHashable: Any]

    // MARK: Initialization

    /// Creates an empty dictionary storage.
    init() {
        dictionary = [AnyHashable: Any]()
    }

    /// Creates a dictionary storage from an existing copy.
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

}

// MARK: - AnyInteger

///
/// An object that wraps a generic integer value.
///

class AnyInteger {

    private let stringGenerator: () -> String
    private let intGenerator: () -> Int

    /// Creates a wrapper from a base integer.
    init<T: FixedWidthInteger>(_ base: T) {

        stringGenerator = {
            return String(base, radix: 10, uppercase: false)
        }

        intGenerator = {
            return Int(base)
        }

    }

    /// The `String` representation of the integer.
    var stringValue: String {
        return stringGenerator()
    }

    /// The `Int` representation of the integer.
    var intValue: Int {
        return intGenerator()
    }

    /// Converts the integer to another integer type or returns `nil` if the target type is too
    /// small to contain the `intValue`.
    func convertingType<T: BinaryInteger & FixedWidthInteger>() -> T? {

        let intValue = self.intValue

        guard T.bitWidth <= Int.bitWidth else {
            return nil
        }

        guard intValue >= T.min && intValue <= T.max else {
            return nil
        }

        return T(intValue)

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
