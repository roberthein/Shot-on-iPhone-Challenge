import Foundation
import SwiftUI
import Observation
import UIKit

@MainActor
@Observable
final class HapticsManager {
    static let shared = HapticsManager()

    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        selectionGenerator.prepare()
    }

    func trigger() {
        selectionGenerator.selectionChanged()
    }
}

private struct HapticsManagerKey: @preconcurrency EnvironmentKey {
    @MainActor
    static var defaultValue: HapticsManager = .shared
}

extension EnvironmentValues {
    var hapticsManager: HapticsManager {
        get { self[HapticsManagerKey.self] }
        set { self[HapticsManagerKey.self] = newValue }
    }
}
