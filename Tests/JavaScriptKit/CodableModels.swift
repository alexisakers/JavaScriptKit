import Foundation
import JavaScriptKit

enum Country: String, Encodable {
    case utopia = "UTOPIA"
}

struct Address: Encodable {
    let line1: String
    let line2: String?
    let zipCode: Int
    let city: String
    let country: Country
}

struct Person: Encodable {
    let firstName: String
    let lastName: String
    let birthDate: Date
    let mainAddress: Address
    let socialMediaURL: URL
    var bestFriends: [Person]?
}

class EmptyObject: Encodable {

    class Void: Encodable {
        func encode(to encoder: Encoder) {}
    }

    let void = Void()

    func encode(to encoder: Encoder) throws {
        var singleValueContainer = encoder.singleValueContainer()
        try singleValueContainer.encode(void)
    }

}

class Image: Encodable {

    let url: URL
    let likeCount: Int
    let location: String
    let hasFilters: Bool
    let user: User

    init(url: URL, likeCount: Int, location: String, hasFilters: Bool, user: User) {
        self.url = url
        self.likeCount = likeCount
        self.location = location
        self.hasFilters = hasFilters
        self.user = user
    }

    enum Keys: String, CodingKey {
        case url, likeCount, location, hasFilters, user
    }

    func encode(with encoder: Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: Keys.self)
        try keyedContainer.encode(url, forKey: .url)
        try keyedContainer.encode(likeCount, forKey: .likeCount)
        try keyedContainer.encode(location, forKey: .location)
        try keyedContainer.encode(user, forKey: .user)
    }

}

struct User: Encodable {
    let displayName: String
    let handle: String
}
