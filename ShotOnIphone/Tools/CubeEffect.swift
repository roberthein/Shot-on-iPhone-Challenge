import Foundation
import SwiftUI
import Observation
import UIKit

@inline(__always) private func cubeAngle(_ phase: Double) -> Angle {
    .degrees(phase.clamped(to: -1 ... 1) * (45 * 1.5))
}

@inline(__always) private func cubeAnchor(_ phase: Double) -> UnitPoint {
    if phase < 0 {
        .trailing
    } else {
        .leading
    }
}

@MainActor
private struct CubeEffect: ViewModifier {
    @Binding var isTransitioning: Bool

    func body(content: Content) -> some View {
        let isTransitioning = isTransitioning
        content
            .scrollTransition(.interactive(timingCurve: .linear), axis: .horizontal) { content, phase in
                content
                    .rotation3DEffect(
                        isTransitioning || phase.isIdentity ? .zero : cubeAngle(phase.value),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: phase.isIdentity ? .center : cubeAnchor(phase.value),
                        perspective: 2.5
                    )
                    .opacity(1 - abs(phase.value * 0.6))
            }
    }
}

extension View {
    func cubeEffect(isTransitioning: Binding<Bool>) -> some View {
        modifier(CubeEffect(isTransitioning: isTransitioning))
    }
}
