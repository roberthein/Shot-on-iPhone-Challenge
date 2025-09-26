import Foundation
import SwiftUI
import tinyTCA

@main
struct tinyStoriesApp: App {
    let store = Store(feature: StoryListFeature())

    var body: some Scene {
        WindowGroup {
            StoryListView(store: store)
                .preferredColorScheme(.dark)
        }
    }
}
