import Foundation
import SwiftUI

public struct BackgroundProtection: ViewModifier {
    let placement: Placement
    let color: Color

    public enum Direction {
        case topToBottom
        case bottomToTop
    }

    public enum Placement {
        case top(CGFloat), bottom(CGFloat), topAndBottom(CGFloat, CGFloat)

        var blurHeightTop: CGFloat {
            switch self {
            case let .top(blurHeight): blurHeight
            case .bottom: .zero
            case let .topAndBottom(blurHeight, _): blurHeight
            }
        }

        var blurHeightBottom: CGFloat {
            switch self {
            case .top: .zero
            case let .bottom(blurHeight): blurHeight
            case let .topAndBottom(_, blurHeight): blurHeight
            }
        }
    }

    public func body(content: Content) -> some View {
        content
            .overlay {
                VStack(spacing: 0) {
                    switch placement {
                    case .top:
                        protectionOverlay(direction: .topToBottom, blurHeight: placement.blurHeightTop)
                        Spacer.zero
                    case .bottom:
                        Spacer.zero
                        protectionOverlay(direction: .bottomToTop, blurHeight: placement.blurHeightBottom)
                    case .topAndBottom:
                        protectionOverlay(direction: .topToBottom, blurHeight: placement.blurHeightTop)
                        Spacer.zero
                        protectionOverlay(direction: .bottomToTop, blurHeight: placement.blurHeightBottom)
                    }
                }
                .allowsHitTesting(false)
                .ignoresSafeArea()
            }
    }

    @ViewBuilder private func protectionOverlay(direction: Direction, blurHeight: CGFloat) -> some View {
        LinearGradient(
            gradient: Gradient(colors: [
                color,
                color.opacity(0)
            ]),
            startPoint: direction == .topToBottom ? .top : .bottom,
            endPoint: direction == .topToBottom ? .bottom : .top
        )
        .frame(height: blurHeight)
    }
}

public extension View {
    func backgroundProtection(
        placement: BackgroundProtection.Placement,
        color: Color
    ) -> some View {
        self.modifier(BackgroundProtection(
            placement: placement,
            color: color
        ))
    }
}
