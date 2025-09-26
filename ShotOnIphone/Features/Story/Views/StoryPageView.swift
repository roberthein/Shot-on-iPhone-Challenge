import Foundation
import SwiftUI
import Observation
import tinyTCA

public struct StoryPageView: View {
    let item: StoryItem
    @Binding var isDragging: Bool
    @Binding var isScrolling: Bool
    @Binding var isTransitioning: Bool
    var onTap: (() -> Void)
    var onDismiss: (() -> Void)

    @Environment(\.displayScale) private var displayScale
    @State private var dragOffset: CGFloat = 0
    private let trigger: CGFloat = 140
    private let minScale: CGFloat = 0.88

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                storyImageView(size: proxy.size)
                storyBottomBar()
                    .offset(y: isTransitioning ? 100 : 0)
                    .animation(.viewTransition, value: isTransitioning)
                    .padding(Padding.outer)
            }
            .clipShape(RoundedRectangle(cornerRadius: isDragging || isScrolling || isTransitioning ? 32 : 0, style: .continuous))
            .animation(.viewTransition, value: isDragging || isScrolling)
            .storyInteraction(
                onTouchDown: { /* no-op */ },
                onTap: onTap,
                onLongPress: {
                    isDragging = true
                },
                onDragging: { offset in
                    dragOffset = max(0, offset.height - StoryInteraction.dragThreshold)
                    isDragging = true
                },
                onTouchUp: {
                    if dragOffset > trigger {
                        onDismiss()
                    } else {
                        withAnimation(.viewTransition) {
                            dragOffset = 0
                        }
                    }

                    isDragging = false
                }
            )
            .scaleEffect(scale(for: dragOffset))
            .offset(y: dragOffset)
        }
    }

    private func scale(for dy: CGFloat) -> CGFloat {
        let maxDrag: CGFloat = 300
        let t = min(max(dy / maxDrag, 0), 1)
        return 1 - (1 - minScale) * t
    }

    @ViewBuilder private func storyImageView(size: CGSize) -> some View {
        Color.black
            .overlay {
                CachedAsyncImage(url: item.imageURL()) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .allowsHitTesting(false)
                } placeholder: {
                    Color.secondary.opacity(0.12)
                        .overlay(ProgressView())
                        .allowsHitTesting(false)
                }
            }

            .backgroundProtection(
                placement: .topAndBottom(150, 250),
                color: .black.opacity(0.8)
            )
    }

    @ViewBuilder private func profileView() -> some View {
        ZStack(alignment: .leading) {
            HStack(alignment: .bottom, spacing: Padding.innerDouble) {

                profileImageView()

                VStack(alignment: .leading, spacing: Padding.innerHalf) {
                    Text("artist".uppercased())
                        .font(.tertiaryCaption)
                        .foregroundStyle(.primaryText)
                    Text(item.story.name)
                        .font(.secondaryTitle)
                        .foregroundStyle(.primaryText)
                }
                .padding(.trailing, Padding.outer)
            }
        }
        .frame(height: 44)
    }

    @ViewBuilder private func profileImageView() -> some View {
        CachedAsyncImage(url: URL(string: item.story.profilePictureURL)) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.mediumInner, style: .continuous))
        } placeholder: {
            Color.secondary.opacity(0.12)
                .frame(width: 36, height: 36)
                .overlay(ProgressView())
                .clipShape(RoundedRectangle(cornerRadius: CornerRadius.mediumInner, style: .continuous))
        }
    }

    @ViewBuilder private func storyBottomBar() -> some View {
        HStack(spacing: Padding.inner) {
            profileView()

            Spacer.zero

            LikeButton(id: item.imageId)
                .padding(.bottom, Padding.innerHalf)
                .padding(.trailing, Padding.innerHalf)
        }
        .padding(.horizontal, Padding.outer)
        .padding(.bottom, Padding.outerDouble)
    }
}
