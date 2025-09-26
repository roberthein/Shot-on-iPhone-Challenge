import Foundation
import SwiftUI

struct LikeButton: View {
    let id: Int
    @AppStorage var isLiked: Bool
    @Environment(\.hapticsManager) private var haptics
    @State private var burstToken: Int = 0

    init(id: Int, store: UserDefaults? = .standard) {
        self.id = id
        _isLiked = AppStorage(wrappedValue: false, "liked.\(id)", store: store)
    }

    var body: some View {
        Button {
            let willLike = !isLiked
            withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) {
                isLiked = willLike
            }
            if willLike {
                burstToken &+= 1
            }
            haptics.trigger()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous)
                    .fill(.glassFill)
                    .overlay {
                        RoundedRectangle(cornerRadius: CornerRadius.medium, style: .continuous)
                            .stroke(.glassStroke)
                    }
                    .frame(width: 44, height: 44)

                Text(Image(systemName: isLiked ? "star.fill" : "star"))
                    .font(.system(size: 18, weight: isLiked ? .bold : .thin, design: .rounded))
                    .foregroundStyle(.white)
                    .scaleEffect(isLiked ? 1.15 : 1.0)
                    .symbolEffect(.bounce, options: .nonRepeating, value: isLiked)
                    .contentTransition(.symbolEffect(.replace))
                    .animation(.bouncy, value: isLiked)
            }
        }
        .buttonStyle(.plain)
        .overlay {
            SparkleBurst(trigger: $burstToken)
                .allowsHitTesting(false)
        }
    }
}

private struct SparkleBurst: View {
    @Binding var trigger: Int

    var body: some View {
        SparkleCore()
            .id(trigger)
    }

    private struct SparkleCore: View {
        @State private var animate = false
        private let count = 10
        private let radius: CGFloat = 100

        var body: some View {
            ZStack {
                ForEach(0..<count, id: \.self) { i in
                    let t = Double(i) / Double(count) * .pi * 2
                    Circle()
                        .fill(.white)
                        .frame(width: 4, height: 4)
                        .opacity(animate ? 0 : 1)
                        .offset(x: animate ? cos(t) * radius : 0,
                                y: animate ? sin(t) * radius : 0)
                        .scaleEffect(animate ? 0.3 : 1)
                        .animation(.easeOut(duration: 0.5), value: animate)
                }
            }
            .frame(width: 100, height: 100)
            .onAppear { animate = true }
        }
    }
}
