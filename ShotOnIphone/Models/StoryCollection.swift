import Foundation

struct StoryCollection: Sendable, Equatable, Identifiable {
    public let id: UUID = UUID()
    public let createdAt: Date = Date()
    public let stories: [Story]

    public init(stories: [Story]) {
        self.stories = stories
    }
}

struct StoryCollectionsResponse: Codable, Sendable {
    let storyCollections: [StoryCollectionResponse]
}

