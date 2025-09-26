import Foundation
import SwiftUI
import Observation
import tinyTCA

struct StoryPager: View {
    @StoreState<StoryFeature> var state: StoryFeature.State
    @Binding var isDragging: Bool
    @Binding var isTransitioning: Bool
    let animation: Namespace.ID
    @State var isScrolling: Bool = false
    var onDismiss: (() -> Void)

    @State private var scrollId: Int?
    @Environment(\.hapticsManager) private var haptics

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack.zero {
                    ForEach(Array(state.items.enumerated()), id: \.offset) { index, item in
                        StoryPageView(
                            item: item,
                            isDragging: $isDragging,
                            isScrolling: $isScrolling,
                            isTransitioning: $isTransitioning,
                            onTap: {
                                $state.send(.jump(newIndex: state.index + 1))
                            },
                            onDismiss: onDismiss
                        )
                        .containerRelativeFrame(.horizontal)
                        .cubeEffect(isTransitioning: $isTransitioning)
                        .matchedGeometryEffect(
                            id: "item\(item.story.id)",
                            in: animation,
                            anchor: .center,
                            isSource: true
                        )
                        .id(index)
                        .zIndex(199 - Double(index))
                    }
                }
                .scrollTargetLayout()
            }
            .onScrollPhaseChange { _, newPhase in
                isScrolling = newPhase.isScrolling
            }
            .scrollPosition(id: $scrollId)
            .scrollTargetBehavior(.paging)
            .scrollIndicators(.hidden)
            .scrollDisabled(isDragging)
            .onScrollPhaseChange { _, phase in
                switch phase {
                case .idle:
                    $state.send(.resume)
                default:
                    $state.send(.pause)
                }
            }
            .onChange(of: state.uiCommand) { oldValue, newValue in
                guard let cmd = newValue, cmd != oldValue else { return }
                switch cmd {
                case let .scrollTo(itemId, animated):
                    let work = { scrollId = itemId }
                    if animated {
                        withAnimation(.easeInOut) {
                            work()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            $state.send(.startNextTimer)
                        }
                    } else {
                        work()
                        $state.send(.startNextTimer)
                    }
                case .finish:
                    onDismiss()
                }
                $state.send(.uiCommandHandled)
            }
            .onChange(of: scrollId) { _, newValue in
                guard let newValue else { return }
                $state.send(.jump(newIndex: newValue))
                haptics.trigger()
            }
            .onChange(of: isDragging) { _, isDragging in
                if isDragging {
                    $state.send(.pause)
                } else {
                    $state.send(.resume)
                }
            }
        }
    }
}
