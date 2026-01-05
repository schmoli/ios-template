import Foundation
import SwiftUI

/// Application lifecycle state
enum AppState: Sendable, Equatable {
    case active
    case inactive
    case background
}

extension AppState {
    /// Convert SwiftUI ScenePhase to AppState
    init(scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            self = .active
        case .inactive:
            self = .inactive
        case .background:
            self = .background
        @unknown default:
            self = .inactive
        }
    }
}
