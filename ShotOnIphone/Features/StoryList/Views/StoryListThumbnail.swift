import Foundation
import SwiftUI

struct StoryListThumbnail: View {
    let url: URL?
    let index: Int

    var body: some View {
        Color.black
            .overlay {
                CachedAsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.secondary.opacity(0.12)
                        .overlay(ProgressView())
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: index == 0 ? CornerRadius.largeInner : CornerRadius.mediumInner,
                    bottomLeadingRadius: CornerRadius.mediumInner,
                    bottomTrailingRadius: CornerRadius.mediumInner,
                    topTrailingRadius: index == 4 ? CornerRadius.largeInner : CornerRadius.mediumInner,
                    style: .continuous
                )
            )
    }
}
