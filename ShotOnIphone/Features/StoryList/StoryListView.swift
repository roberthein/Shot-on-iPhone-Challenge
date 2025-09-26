import Foundation
import SwiftUI
import tinyTCA
import tinyAPI

struct StoryListView: View {
    @StoreState<StoryListFeature> private var state: StoryListFeature.State
    @Namespace private var animation
    @State private var isTransitioning: Bool = false
    @State private var didLaunch: Bool = false

    init(store: Store<StoryListFeature>) {
        self._state = StoreState(store)
    }

    @State private var selectedStoryCollection: StoryCollection?
    @State private var showingStory = false

    private var storyCollections: [StoryCollection] {
        if case let .success(sc) = state.storyCollections { return sc }
        return []
    }

    var body: some View {
        ZStack {
            storyListView()
                .opacity(showingStory ? 0.8 : 1)
                .if(didLaunch) { $0.scaleEffect(showingStory ? 1.3 : 1) }
                .animation(.viewTransition, value: showingStory)

            if showingStory, let collection = selectedStoryCollection {
                storyView(collection: collection)
            }
        }
        .onAppear {
            if case .idle = state.storyCollections {
                $state.send(.loadStoryCollections)
            }
        }
    }

    @ViewBuilder private func storyView(collection: StoryCollection) -> some View {
        StoryView(
            store: Store(feature: StoryFeature(storyCollection: collection)),
            animation: animation,
            isTransitioning: $isTransitioning,
            onDismiss: dismissStory
        )
    }

    @ViewBuilder private func headerView() -> some View {
        VStack(spacing: Padding.innerDouble) {
            Image(systemName: "apple.logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 32, maxHeight: 32)

            Text("Shot on iPhone Challenge")
                .font(.primaryTitle)
                .foregroundStyle(.primaryText)

            Text("Nominees listed per category:")
                .font(.primarySubtitle)
                .foregroundStyle(.primaryText)
                .padding(.top, Padding.inner)
                .opacity(storyCollections.isEmpty ? 0 : 1)
                .animation(.viewIntro, value: storyCollections.isEmpty)
        }
    }

    @ViewBuilder private func footerView() -> some View {
        VStack(spacing: Padding.inner) {
            Text("Vote for your favorite shots by\nselecting the \(Image(systemName: "star.fill"))")
                .font(.primaryCaption)
                .foregroundStyle(.primaryText)
                .multilineTextAlignment(.center)
        }
    }

    @ViewBuilder private func storyListView() -> some View {
        ScrollView {
            VStack(spacing: Padding.outerDouble) {
                Spacer(minLength: Padding.outerDouble)

                headerView()
                    .opacity(showingStory ? 0 : 1)

                FlowLayout(spacing: Padding.outer, rowAlignment: .center) {
                    ForEach(Array(storyCollections.enumerated()), id: \.element.id) { index, storyCollection in
                        StoryListCell(
                            state: $state.binding,
                            storyCollection: storyCollection,
                            storyCollectionNumber: index + 1,
                            storyCategory: StoryCategory.allCases[index],
                            animation: animation,
                            showingStory: showingStory,
                            onTap: { present(storyCollection) }
                        )
                        .id("story-\(storyCollection.id)")
                        .frame(width: 250)
                        .transition(.scale(scale: 0.8, anchor: .center).combined(with: .opacity).combined(with: .offset(y: Double(index) * -50)).animation(.viewIntro.delay(Double(index) * 0.1)))
                    }
                }

                if !storyCollections.isEmpty {
                    footerView()
                        .transition(.opacity.combined(with: .offset(y: -200)).animation(.viewIntro))
                        .opacity(showingStory ? 0 : 1)
                } else {
                    ProgressView()
                        .offset(y: -50)
                        .transition(.opacity)
                }

                Spacer(minLength: Padding.outerDouble)
            }
            .frame(maxHeight: .infinity)
        }
        .offset(y: storyCollections.isEmpty ? 100 : 0)
        .animation(.viewIntro, value: storyCollections)
    }

    private func present(_ storyCollection: StoryCollection) {
        didLaunch = true
        $state.send(.selectStory(storyCollection.id))
        selectedStoryCollection = storyCollection
        isTransitioning = true

        withAnimation(.viewTransition) {
            showingStory = true
        } completion: {
            isTransitioning = false
        }
    }

    private func dismissStory() {
        isTransitioning = true
        withAnimation(.viewTransition) {
            showingStory = false
        } completion: {
            selectedStoryCollection = nil
            isTransitioning = false
            $state.send(.selectStory(nil))
        }
    }
}

