import Foundation
import SwiftUI
import tinyAPI
import tinyTCA

struct StoryListFeature: Feature {
    struct State: Sendable, Equatable {
        var storyCollections: RequestState<[StoryCollection]> = .idle
        var errorMessage: String?
        var storyItems: [UUID: [StoryItem]] = [:]
        var selectedStory: UUID?
    }

    enum Action: Sendable {
        case loadStoryCollections
        case storyCollectionsResponse(Result<StoryCollectionsResponse, TinyAPIError>)
        case selectStory(UUID?)
        case clearError
    }

    var initialState: State {
        State()
    }

    func reducer(state: inout State, action: Action) throws {
        switch action {
        case .loadStoryCollections:
            state.storyCollections = .loading
            state.errorMessage = nil

        case .storyCollectionsResponse(.success(let response)):
            let storyCollections = transformToStoryCollections(response)
            state.storyCollections = .success(storyCollections)
            state.storyItems = storyCollections.reduce([:]) { partialResult, storyCollection in
                var result = partialResult
                result[storyCollection.id] = storyCollection.stories.map { story in
                    StoryItem(id: story.id, story: story, seed: "story_\(story.id)")
                }
                return result
            }
        case .storyCollectionsResponse(.failure(let error)):
            state.storyCollections = .failure(error.localizedDescription)
            state.errorMessage = error.localizedDescription

        case let .selectStory(id):
            state.selectedStory = id

        case .clearError:
            state.errorMessage = nil
        }
    }

    func effect(for action: Action, state: State) async throws -> Action? {
        switch action {
        case .loadStoryCollections:
            do {
                let response = try await APIClientDependency.mock.client.request(
                    StoryCollectionsEndpoint.getStoryCollections,
                    as: StoryCollectionsResponse.self
                )

                return .storyCollectionsResponse(.success(response))
            } catch let error as TinyAPIError {
                return .storyCollectionsResponse(.failure(error))
            } catch {
                return .storyCollectionsResponse(.failure(.networkError(error.localizedDescription)))
            }

        default:
            return nil
        }
    }

    private func transformToStoryCollections(_ response: StoryCollectionsResponse) -> [StoryCollection] {
        return response.storyCollections.map { storyCollectionResponse in
            StoryCollection(stories: storyCollectionResponse.stories)
        }
    }
}
