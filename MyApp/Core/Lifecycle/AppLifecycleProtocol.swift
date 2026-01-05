import Foundation

/// Protocol for observing application lifecycle events
@preconcurrency
protocol AppLifecycleProtocol: Sendable {
    /// Current application state
    var currentState: AppState { get async }

    /// Register handler for app appearing (first launch)
    func onAppear(_ handler: @escaping @Sendable () async -> Void) async

    /// Register handler for app entering foreground
    func onForeground(_ handler: @escaping @Sendable () async -> Void) async

    /// Register handler for app entering background
    func onBackground(_ handler: @escaping @Sendable () async -> Void) async

    /// Register handler for app becoming inactive
    func onInactive(_ handler: @escaping @Sendable () async -> Void) async
}
