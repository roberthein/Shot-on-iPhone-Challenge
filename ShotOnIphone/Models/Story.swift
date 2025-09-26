import Foundation

public struct Story: Codable, Sendable, Equatable, Identifiable {
    public let id: Int
    public let name: String
    public let profilePictureURL: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case profilePictureURL = "profile_picture_url"
    }
}

struct StoryCollectionResponse: Codable {
    let stories: [Story]
}

