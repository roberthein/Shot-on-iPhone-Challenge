import Foundation
import SwiftUI
import Observation
import tinyTCA

struct StoryView: View {
    @StoreState<StoryFeature> private var state: StoryFeature.State
    let animation: Namespace.ID
    @Binding var isTransitioning: Bool
    private var onDismiss: (() -> Void)
    @State private var isDragging: Bool = false

    init(store: Store<StoryFeature>, animation: Namespace.ID, isTransitioning: Binding<Bool>, onDismiss: @escaping (() -> Void)) {
        _state = StoreState(store)
        self.animation = animation
        self._isTransitioning = isTransitioning
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.black
                .opacity(isDragging ? 0 : 1)
                .animation(.easeOut(duration: 0.2), value: isDragging)
                .ignoresSafeArea()

            StoryPager(
                state: _state,
                isDragging: $isDragging,
                isTransitioning: $isTransitioning,
                animation: animation,
                onDismiss: onDismiss
            )
            .ignoresSafeArea()

            StoryProgressBars(
                state: $state.binding
            )
            .padding(.top, Padding.outer)
            .padding(.horizontal, Padding.outerHalf)
            .allowsHitTesting(false)
            .offset(y: isTransitioning || isDragging ? -100 : 0)
            .animation(.viewTransition, value: isTransitioning || isDragging)
        }
        .onChange(of: isTransitioning) { _, isTransitioning in
            switch isTransitioning {
            case false: $state.send(.begin(index: state.index))
            case true: $state.send(.pause)
            }
        }
    }
}
