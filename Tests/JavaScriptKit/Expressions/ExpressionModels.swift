import Foundation

/// A mock enum that lists fonts.
enum ReaderFont: String, Codable {
    case sanFrancisco, arial, helvetica, times
}

/// A mock enum that lists text sizes.
enum ReaderSize: Int, Codable {
    case small = 14
    case large = 17
    case xLarge = 20
}

/// A mock enum of targets.
enum MockTargetType: String, Codable {
    case app, executable, framework, unitTest
}

/// A mock struct.
struct MockTarget: Codable, Equatable {


    let name: String
    let targetType: MockTargetType
    let categories: [String]

    static func ==(lhs: MockTarget, rhs: MockTarget) -> Bool {
        return (lhs.name == rhs.name) && (lhs.targetType == rhs.targetType) && (lhs.categories == rhs.categories)
    }

}

/// A structure that always fails encoding.
struct NotSoEncodable: Encodable {

    let name: String

    func encode(to encoder: Encoder) throws {
        throw EncodingError.invalidValue(name,
                                         EncodingError.Context(codingPath: [],
                                                               debugDescription: "NotSoEncodable structures cannot be encoded."))
    }

}
