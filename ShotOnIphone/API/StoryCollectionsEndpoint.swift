import Foundation
import tinyAPI

enum StoryCollectionsEndpoint {
    case getStoryCollections
}

extension StoryCollectionsEndpoint: TinyAPIEndpoint {
    nonisolated var baseURL: String { "" }
    nonisolated var path: String { "/stories" }
    nonisolated var method: HTTPMethod { .GET }
    nonisolated var body: Data? { nil }
    nonisolated var headers: [String: String]? { nil }
    nonisolated var queryItems: [URLQueryItem]? { nil }
}
