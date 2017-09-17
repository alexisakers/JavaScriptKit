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
