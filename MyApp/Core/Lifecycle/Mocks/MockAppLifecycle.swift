import Foundation

/// Mock implementation of AppLifecycleProtocol for testing
actor MockAppLifecycle: AppLifecycleProtocol {
    private(set) var currentState: AppState = .active

    private var appearHandlers: [@Sendable () async -> Void] = []
    private var foregroundHandlers: [@Sendable () async -> Void] = []
    private var backgroundHandlers: [@Sendable () async -> Void] = []
    private var inactiveHandlers: [@Sendable () async -> Void] = []

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

    // Test helpers
    func simulateAppear() async {
        currentState = .active
        for handler in appearHandlers {
            await handler()
        }
    }

    func simulateForeground() async {
        currentState = .active
        for handler in foregroundHandlers {
            await handler()
        }
    }

    func simulateBackground() async {
        currentState = .background
        for handler in backgroundHandlers {
            await handler()
        }
    }

    func simulateInactive() async {
        currentState = .inactive
        for handler in inactiveHandlers {
            await handler()
        }
    }

    func reset() {
        appearHandlers.removeAll()
        foregroundHandlers.removeAll()
        backgroundHandlers.removeAll()
        inactiveHandlers.removeAll()
        currentState = .active
    }
}
