import Foundation
import SwiftUI
import Observation
import tinyTCA

public struct StoryProgressBarView: View {
    let count: Int
    let currentIndex: Int
    let currentProgress: Double

    public init(count: Int, currentIndex: Int, currentProgress: Double) {
        self.count = max(count, 0)
        self.currentIndex = min(max(currentIndex, 0), max(count - 1, 0))
        self.currentProgress = currentProgress.clamped(to: 0...1)
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.glassFill)
                            .overlay {
                                Capsule()
                                    .stroke(.glassStroke.opacity(0.2))
                            }
                        Capsule()
                            .fill(.white.opacity(0.9))
                            .frame(width: fillWidth(for: index, totalWidth: geo.size.width))
                    }
                }
                .frame(height: 8)
            }
        }
        .frame(height: 8)
    }

    private func fillWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
        if index < currentIndex { return totalWidth }
        if index > currentIndex { return 0 }
        return totalWidth * currentProgress
    }
}
