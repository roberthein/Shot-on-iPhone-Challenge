import Foundation
import SwiftUI
import tinyTCA

struct StoryFeature: Feature {
    let storyCollection: StoryCollection
    let items: [StoryItem]

    init(storyCollection: StoryCollection) {
        self.storyCollection = storyCollection
        self.items = storyCollection.stories.map { story in
            StoryItem(id: story.id, story: story, seed: "story_\(story.id)")
        }
    }

    enum UICommand: Sendable, Equatable {
        case scrollTo(Int, animated: Bool = true)
        case finish
    }

    struct State: Sendable, Equatable {
        let items: [StoryItem]
        let segmentDuration: TimeInterval
        var index: Int = 0
        var startedAt: Date? = nil
        var pausedAccumulated: TimeInterval = 0
        var pauseBeganAt: Date? = nil
        var timerGeneration: UInt64 = 0
        var uiCommand: UICommand? = nil
        var isPaused: Bool { pauseBeganAt != nil }

        init(items: [StoryItem]) {
            self.items = items
            self.segmentDuration = 3
        }

        func progress(at now: Date = .init()) -> Double {
            guard let start = startedAt else { return 0 }
            let activePause = pauseBeganAt.map { now.timeIntervalSince($0) } ?? 0
            let elapsed = max(0, now.timeIntervalSince(start) - pausedAccumulated - activePause)
            return (elapsed / segmentDuration).clamped(to: 0 ... 1)
        }

        func remaining(at now: Date = .init()) -> TimeInterval {
            max(0, segmentDuration * (1 - progress(at: now)))
        }

        mutating func resetTimer() {
            startedAt = Date()
            pausedAccumulated = 0
            pauseBeganAt = nil
        }

        mutating func invalidateTimerCompletion() {
            timerGeneration &+= 1
        }
    }

    enum Action: Sendable {
        case begin(index: Int)
        case pause
        case resume
        case resetAndPlay
        case jump(newIndex: Int)
        case startTimer(delay: TimeInterval)
        case stopTimer
        case timerFired(generation: UInt64)
        case startNextTimer
        case uiCommandHandled
    }

    var initialState: State { .init(items: items) }

    func reducer(state: inout State, action: Action) throws {
        switch action {
        case let .begin(index):
            state.index = index.clamped(to: 0 ... max(state.items.count - 1, 0))
            state.invalidateTimerCompletion()
        case .pause:
            guard !state.isPaused else { return }
            state.pauseBeganAt = Date()
            state.invalidateTimerCompletion()
        case .resume:
            guard let began = state.pauseBeganAt else { return }
            state.pausedAccumulated += Date().timeIntervalSince(began)
            state.pauseBeganAt = nil
        case .resetAndPlay:
            state.resetTimer()
            state.invalidateTimerCompletion()
        case let .jump(newIndex):
            let clamped = newIndex.clamped(to: 0 ... max(state.items.count - 1, 0))
            guard clamped != state.index else { return }
            state.index = clamped
            state.resetTimer()
            state.invalidateTimerCompletion()
            state.uiCommand = .scrollTo(state.index, animated: false)
        case let .timerFired(gen):
            guard gen == state.timerGeneration else { return }
            state.resetTimer()

            if state.index < state.items.count - 1 {
                state.index += 1
                state.uiCommand = .scrollTo(state.index, animated: true)
            } else {
                state.uiCommand = .finish
            }
        case .startTimer:
            state.invalidateTimerCompletion()
        case .stopTimer:
            state.invalidateTimerCompletion()
        case .startNextTimer:
            break
        case .uiCommandHandled:
            state.uiCommand = nil
        }
    }

    func effect(for action: Action, state: State) async throws -> Action? {
        switch action {
        case .begin:
            return .resetAndPlay
        case .pause:
            return .stopTimer
        case .resume:
            let remaining = state.remaining()
            if remaining < 0.1 {
                return .resetAndPlay
            } else {
                return .startTimer(delay: remaining)
            }
        case .resetAndPlay:
            return .startTimer(delay: state.segmentDuration)
        case let .startTimer(delay):
            guard delay > 0 else {
                return nil
            }
            let gen = state.timerGeneration
            let clock = ContinuousClock()
            try await clock.sleep(for: .seconds(delay), tolerance: .milliseconds(16))
            return .timerFired(generation: gen)
        case .timerFired:
            return nil
        case .startNextTimer:
            if state.index < state.items.count - 1 {
                return .startTimer(delay: state.segmentDuration)
            } else {
                return .stopTimer
            }
        case .jump:
            return .startTimer(delay: state.segmentDuration)
        default:
            return nil
        }
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
