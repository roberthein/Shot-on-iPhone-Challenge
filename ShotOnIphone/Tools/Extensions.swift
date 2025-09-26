import Foundation
import SwiftUI

extension Spacer {
    static var zero: Self {
        .init(minLength: .zero)
    }
}

extension HStack {
    @inlinable static func zero(alignment: VerticalAlignment = .center, @ViewBuilder content: () -> Content) -> Self {
        .init(alignment: alignment, spacing: .zero, content: content)
    }
}

extension VStack {
    @inlinable static func zero(alignment: HorizontalAlignment = .center, @ViewBuilder content: () -> Content) -> Self {
        .init(alignment: alignment, spacing: .zero, content: content)
    }
}

public extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
