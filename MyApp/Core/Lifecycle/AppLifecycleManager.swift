import Foundation
import SwiftUI

/// Manages application lifecycle events and handler registration
actor AppLifecycleManager: AppLifecycleProtocol {
    static let shared = AppLifecycleManager()

    private(set) var currentState: AppState = .active

    private var appearHandlers: [@Sendable () async -> Void] = []
    private var foregroundHandlers: [@Sendable () async -> Void] = []
    private var backgroundHandlers: [@Sendable () async -> Void] = []
    private var inactiveHandlers: [@Sendable () async -> Void] = []

    private var hasAppeared = false

    private init() {}

    func onAppear(_ handler: @escaping @Sendable () async -> Void) {
        appearHandlers.append(handler)
    }

    func onForeground(_ handler: @escaping @Sendable () async -> Void) {
        foregroundHandlers.append(handler)
    }

    func onBackground(_ handler: @escaping @Sendable () async -> Void) {
        backgroundHandlers.append(handler)
    }

    func onInactive(_ handler: @escaping @Sendable () async -> Void) {
        inactiveHandlers.append(handler)
    }

    /// Update state based on SwiftUI ScenePhase
    func updateState(_ scenePhase: ScenePhase) {
        let newState = AppState(scenePhase: scenePhase)
        let oldState = currentState
        currentState = newState

        // Trigger appropriate handlers
        Task {
            // First appearance
            if !hasAppeared {
                hasAppeared = true
                await executeHandlers(appearHandlers)
            }

            // State transitions
            if oldState != newState {
                switch newState {
                case .active:
                    if oldState == .background || oldState == .inactive {
                        await executeHandlers(foregroundHandlers)
                    }
                case .background:
                    await executeHandlers(backgroundHandlers)
                case .inactive:
                    await executeHandlers(inactiveHandlers)
                }
            }
        }
    }

    private func executeHandlers(_ handlers: [@Sendable () async -> Void]) async {
        await withTaskGroup(of: Void.self) { group in
            for handler in handlers {
                group.addTask {
                    await handler()
                }
            }
        }
    }
}
