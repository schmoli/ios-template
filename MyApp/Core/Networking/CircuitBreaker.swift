import Foundation

/// Thread-safe circuit breaker for managing endpoint failures.
///
/// Prevents hammering failing endpoints by transitioning through states:
/// - closed: Normal operation, requests allowed
/// - open: Too many failures, requests blocked for resetTimeout
/// - halfOpen: Testing if endpoint recovered
actor CircuitBreaker {

    /// Circuit breaker states
    enum State: Equatable, Sendable {
        case closed       // Normal operation
        case open         // Failing fast, not trying
        case halfOpen     // Testing if recovered
    }

    /// Tracks state per endpoint
    private var endpointStates: [String: EndpointState] = [:]

    /// State for a single endpoint
    private struct EndpointState {
        var state: State = .closed
        var consecutiveFailures: Int = 0
        var lastFailureTime: Date?
    }

    /// Number of consecutive failures before opening circuit
    private let failureThreshold = 5

    /// Time to wait before attempting recovery (seconds)
    private let resetTimeout: TimeInterval = 60.0

    /// Current state for the default endpoint
    var state: State {
        endpointStates.values.first?.state ?? .closed
    }

    /// Check if request should be allowed for endpoint.
    /// - Parameter endpoint: The endpoint host (e.g., "api.example.com")
    /// - Throws: APIError.circuitBreakerOpen if circuit is open
    /// - Returns: true if request is allowed
    func shouldAllowRequest(for endpoint: String) throws -> Bool {
        let endpointState = getOrCreateState(for: endpoint)

        switch endpointState.state {
        case .closed:
            return true

        case .open:
            // Check if reset timeout has elapsed
            if let lastFailure = endpointState.lastFailureTime,
               Date().timeIntervalSince(lastFailure) >= resetTimeout {
                // Try half-open
                updateState(for: endpoint, to: .halfOpen)
                return true
            } else {
                let resetAt = (endpointState.lastFailureTime ?? Date()).addingTimeInterval(resetTimeout)
                throw APIError.circuitBreakerOpen(endpoint: endpoint, resetAt: resetAt)
            }

        case .halfOpen:
            return true
        }
    }

    /// Record a successful request for endpoint.
    /// - Parameter endpoint: The endpoint host
    func recordSuccess(for endpoint: String) {
        var state = getOrCreateState(for: endpoint)
        state.state = .closed
        state.consecutiveFailures = 0
        state.lastFailureTime = nil
        endpointStates[endpoint] = state
    }

    /// Record a failed request for endpoint.
    /// - Parameter endpoint: The endpoint host
    func recordFailure(for endpoint: String) {
        var state = getOrCreateState(for: endpoint)
        state.consecutiveFailures += 1
        state.lastFailureTime = Date()

        if state.consecutiveFailures >= failureThreshold {
            state.state = .open
        }

        endpointStates[endpoint] = state
    }

    /// Get consecutive failure count for endpoint (for testing).
    /// - Parameter endpoint: The endpoint host
    /// - Returns: Number of consecutive failures
    func consecutiveFailures(for endpoint: String) -> Int {
        return endpointStates[endpoint]?.consecutiveFailures ?? 0
    }

    // MARK: - Private Helpers

    private func getOrCreateState(for endpoint: String) -> EndpointState {
        if let existing = endpointStates[endpoint] {
            return existing
        }
        let newState = EndpointState()
        endpointStates[endpoint] = newState
        return newState
    }

    private func updateState(for endpoint: String, to newState: State) {
        var state = getOrCreateState(for: endpoint)
        state.state = newState
        endpointStates[endpoint] = state
    }
}
