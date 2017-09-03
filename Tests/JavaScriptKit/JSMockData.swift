import Foundation
import JavaScriptKit



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

    }

}

struct User: Encodable {
    let displayName: String
    let handle: String

    enum Keys: String, CodingKey {
        case displayName, handle
    }

    func encode(with encoder: Encoder) throws {

    }


}
