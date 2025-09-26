import Foundation
import SwiftUI
import Observation
import tinyTCA

struct StoryProgressBars: View {
    @Binding var state: StoryFeature.State

    var body: some View {
        TimelineView(.animation(minimumInterval: 1/15)) { _ in
            StoryProgressBarView(
                count: state.items.count,
                currentIndex: state.index,
                currentProgress: state.progress()
            )
        }
    }
}
