import Foundation
import SwiftUI
import tinyTCA

struct StoryListCell: View {
    @Binding var state: StoryListFeature.State
    let storyCollection: StoryCollection
    let storyCollectionNumber: Int
    let storyCategory: StoryCategory
    let animation: Namespace.ID
    let showingStory: Bool
    let onTap: () -> Void

    @Environment(\.hapticsManager) private var haptics
    @State private var isTouching: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {
            if let items = state.storyItems[storyCollection.id] {
                MasonryLayout(columns: 5, spacing: Padding.innerHalf) {
                    ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                        StoryListThumbnail(url: item.imageURL(), index: index)
                            .aspectRatio(item.ratio, contentMode: .fill)
                            .matchedGeometryEffect(
                                id: "item\(item.story.id)",
                                in: animation,
                                anchor: .center,
                                isSource: true
                            )
                            .opacity(showingStory && state.selectedStory == storyCollection.id ? 0 : 1)
                            .animation(.viewTransition, value: showingStory)
                            .zIndex(99 - Double(index))
                    }
                }
                .padding(Padding.outerHalf)
                .padding(.bottom, 30)
            }

            captionView()
        }
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
                    .fill(.black)

                RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
                    .fill(.glassFill)
            }
        }
        .overlay {
            RoundedRectangle(cornerRadius: CornerRadius.large, style: .continuous)
                .stroke(.glassStroke, lineWidth: 0.7)
        }
        .contentShape(.rect)
        .scaleEffect(isTouching ? 0.95 : 1)
        .animation(.viewTouch, value: isTouching)
        .storyInteraction(
            onTouchDown: {
                isTouching = true
                haptics.trigger()
            },
            onTap: {
                onTap()
            },
            onLongPress: { /* no-op */ },
            onDragging: { _ in /* no-op */ },
            onTouchUp: {
                isTouching = false
                haptics.trigger()
            }
        )
    }

    @ViewBuilder private func captionView() -> some View {
        ZStack {
            UnevenRoundedRectangle(bottomLeadingRadius: CornerRadius.largeInner, bottomTrailingRadius: CornerRadius.largeInner, style: .continuous)
                .fill(.ultraThinMaterial)

            UnevenRoundedRectangle(bottomLeadingRadius: CornerRadius.largeInner, bottomTrailingRadius: CornerRadius.largeInner, style: .continuous)
                .fill(.glassFill.opacity(0.2))

            categoryView()
        }
        .frame(height: 60)
    }

    @ViewBuilder private func categoryView() -> some View {
        HStack.zero {
            VStack(spacing: Padding.innerHalf) {
                HStack(spacing: Padding.inner) {
                    Text("Category:")
                        .font(.primaryCaption)

                    Text(storyCategory.rawValue.uppercased())
                        .font(.secondaryCaption)
                        .foregroundStyle(.primaryText)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule(style: .continuous)
                                .fill(.glassFill)
                                .overlay {
                                    Capsule()
                                        .stroke(.glassStroke, lineWidth: 0.7)
                                }
                        )

                    Spacer.zero
                }

                HStack.zero {
                    Text("\(storyCollection.stories.count) nominees".uppercased())
                        .font(.tertiaryCaption)
                        .foregroundStyle(.secondaryText)

                    Spacer.zero
                }
            }

            Spacer.zero

            Text(Image(systemName: "chevron.right"))
                .font(.tertiaryCaption)
                .foregroundStyle(.secondaryText)
                .padding(.trailing, Padding.inner)
        }
        .padding(Padding.outer)
    }
}
