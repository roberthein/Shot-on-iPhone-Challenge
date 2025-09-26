import Foundation
import SwiftUI

public struct StoryInteraction: ViewModifier {
    var onTouchDown: () -> Void
    var onTap: () -> Void
    var onLongPress: () -> Void
    var onDragging: (CGSize) -> Void
    var onTouchUp: () -> Void

    static let dragThreshold: CGFloat = 30
    static let longPressThreshold: CGFloat = 0.1

    @State private var timer: Timer?
    @State private var activity: Activity = .up {
        didSet {
            guard self.activity != oldValue else {
                return
            }

            switch self.activity {
            case .touching:
                self.onTouchDown()
            case .longPressing:
                self.onLongPress()
            case let .dragging(translation):
                self.onDragging(translation)
            case .up:
                self.onTouchUp()
            }
        }
    }

    @GestureState var dragValue: DragGesture.Value?


    public func body(content: Content) -> some View {
        content
            .onTapGesture {
                guard self.activity.allowsTap else {
                    return
                }
                self.onTap()
                self.activity = .up
            }
            .onLongPressGesture(minimumDuration: .infinity, maximumDistance: Self.dragThreshold, perform: {}) { pressing in
                if pressing {
                    self.activity = .touching
                    self.startTimer()
                } else {
                    guard !self.activity.isDragging else {
                        return
                    }
                    self.activity = .up
                    self.stopTimer()
                }
            }
            .simultaneousGesture(self.dragGesture)
            .onChange(of: self.dragValue) { _, newValue in
                if newValue == nil, self.activity.isDragging {
                    self.activity = .up
                }
            }
    }


    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: Self.dragThreshold, coordinateSpace: .global)
            .updating(self.$dragValue, body: { newValue, dragValue, _ in
                dragValue = newValue
            })
            .onChanged { value in
                guard self.activity.isLongPressing || self.activity.isDragging else {
                    return
                }
                self.activity = .dragging(value.translation)
            }
            .onEnded { _ in
                self.activity = .up
            }
    }


    private func startTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: Self.longPressThreshold, repeats: false) { _ in
            Task { @MainActor in
                self.activity = .longPressing
            }
        }
    }

    private func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
}


private extension StoryInteraction {
    enum Activity: Equatable {
        case touching
        case longPressing
        case dragging(CGSize)
        case up

        var isTouching: Bool { self == .touching }
        var isLongPressing: Bool { self == .longPressing }
        var isDragging: Bool { self != .touching && self != .longPressing && self != .up }
        var isUp: Bool { self == .up }
        var allowsTap: Bool { self.isTouching || self.isUp }
    }
}


public extension View {
    func storyInteraction(
        onTouchDown: @escaping () -> Void,
        onTap: @escaping () -> Void,
        onLongPress: @escaping () -> Void,
        onDragging: @escaping (CGSize) -> Void,
        onTouchUp: @escaping () -> Void
    ) -> some View {
        modifier(StoryInteraction(
            onTouchDown: onTouchDown,
            onTap: onTap,
            onLongPress: onLongPress,
            onDragging: onDragging,
            onTouchUp: onTouchUp
        ))
    }
}
