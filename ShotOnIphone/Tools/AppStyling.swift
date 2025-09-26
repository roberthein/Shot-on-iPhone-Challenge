import Foundation
import SwiftUI

extension Animation {
    static var viewIntro: Animation {
        .spring(response: 1.2, dampingFraction: 0.7)
    }
    static var viewTransition: Animation {
        .spring(response: 0.5, dampingFraction: 0.85)
    }
    static var viewTouch: Animation {
        .spring(response: 0.2, dampingFraction: 0.8)
    }
}

struct Padding {
    static let outer: CGFloat = 12
    static let outerDouble: CGFloat = outer * 2
    static let outerHalf: CGFloat = outer / 2

    static let inner: CGFloat = 4
    static let innerDouble: CGFloat = inner * 2
    static let innerHalf: CGFloat = inner / 2
}

struct CornerRadius {
    static let small: CGFloat = 8
    static let smallInner: CGFloat = 6

    static let medium: CGFloat = 12
    static let mediumInner: CGFloat = 10

    static let large: CGFloat = 24
    static let largeInner: CGFloat = 20
}

extension Font {
    static let primaryTitle: Self = .system(size: 20, weight: .regular, design: .rounded)
    static let secondaryTitle: Self = .system(size: 18, weight: .regular, design: .rounded)

    static let primarySubtitle: Self = .system(size: 14, weight: .thin, design: .rounded)

    static let primaryCaption: Self = .system(size: 13, weight: .thin, design: .rounded)
    static let secondaryCaption: Self = .system(size: 12, weight: .semibold, design: .rounded)
    static let tertiaryCaption: Self = .system(size: 10, weight: .semibold, design: .rounded)
}

extension ShapeStyle where Self == Color {
    static var primaryText: Self { .white.opacity(0.9) }
    static var secondaryText: Self { .white.opacity(0.5) }
}

extension ShapeStyle where Self == LinearGradient {

    static var glassFill: AnyShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.20),
                    Color.white.opacity(0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    static var glassStroke: AnyShapeStyle {
        AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color.white.opacity(0.7),
                    Color.white.opacity(0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}
