import Foundation

enum JSEncodingContainer {

    case singleValue(JSSingleValue)
    case unkeyed(ArrayRef)
    case keyed(DictionaryRef)

    var type: String {

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

class ArrayRef {

    var array = [Any]()

    func append(_ element: Any) {
        array.append(element)
    }

    func insert(_ value: Any, at index: Int) {
        array.insert(value, at: index)
    }

    func appendSingleValue(_ value: JSSingleValue) {

        switch value {
        case .boolean(let bool):
            array.append(bool)
        case .double(let double):
            array.append(double)
        case .float(let float):
            array.append(float)
        case .integer(let integer):
            array.append(integer.makeInt())
        case .string(let string):
            array.append(string)
        default:
            break
        }

    }

    var count: Int {
        return array.count
    }

}

class DictionaryRef {

    var dictionary = [String: Any]()

    subscript(key: String) -> Any? {
        get {
            return dictionary[key]
        }
        set {
            dictionary[key] = newValue
        }
    }

    subscript<Key: CodingKey>(key: Key) -> Any? {
        get {
            return dictionary[key.stringValue]
        }
        set {
            dictionary[key.stringValue] = newValue
        }
    }

    func setSingleValue<Key: CodingKey>(_ singleValue: JSSingleValue, forKey key: Key) {

        switch singleValue {
        case .boolean(let bool):
            dictionary[key.stringValue] = bool
        case .double(let double):
            dictionary[key.stringValue] = double
        case .float(let float):
            dictionary[key.stringValue] = float
        case .integer(let integer):
            dictionary[key.stringValue] = integer.makeInt()
        case .string(let string):
            dictionary[key.stringValue] = string
        default:
            break
        }

    }

}

///
/// A storage container for JavaScript encoder/decoder.
///

enum JSSingleValue {

    /// A `null` value.
    case null

    /// A Boolean value.
    case boolean(Bool)

    /// A String.
    case string(String)

    /// An integer value.
    case integer(AnyInteger)

    /// A Float value.
    case float(Float)

    /// A Double value.
    case double(Double)

    /// An empty object.
    case emptyObject

    var underlyingValue: Any {

        switch self {
        case .null:
            return NSNull()
        case .boolean(let bool):
            return bool
        case .string(let string):
            return string
        case .integer(let integer):
            return integer.makeInt()
        case .float(let float):
            return float
        case .double(let double):
            return double
        case .emptyObject:
            return [String: Any]()
        }


    }

}

class AnyInteger {

    private let stringGenerator: () -> String
    private let intGenerator: () -> Int

    init<T: FixedWidthInteger>(_ base: T) {

        stringGenerator = {
            return String(base, radix: 10, uppercase: false)
        }

        intGenerator = {
            return Int(base)
        }

    }

    func makeString() -> String {
        return stringGenerator()
    }

    func makeInt() -> Int {
        return intGenerator()
    }

}
