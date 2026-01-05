import Foundation

/// Configuration for retry behavior on network failures.
struct RetryPolicy: Sendable {
    /// Maximum number of retry attempts
    let maxAttempts: Int = 3

    /// Base delay in seconds for exponential backoff
    let baseDelay: TimeInterval = 1.0

    /// Calculate delay for a given attempt using exponential backoff.
    /// - Parameter attempt: The attempt number (1-indexed)
    /// - Returns: Delay in seconds (1s, 2s, 4s)
    func delay(for attempt: Int) -> TimeInterval {
        return baseDelay * pow(2.0, Double(attempt - 1))
    }

    /// Determine if an error should be retried.
    /// - Parameters:
    ///   - error: The URLError that occurred
    ///   - attempt: Current attempt number (default 1)
    /// - Returns: true if should retry, false otherwise
    func shouldRetry(error: URLError, attempt: Int = 1) -> Bool {
        guard attempt < maxAttempts else { return false }

        let retryableCodes: Set<URLError.Code> = [
            .networkConnectionLost,
            .timedOut,
            .cannotConnectToHost,
            .notConnectedToInternet
        ]

        return retryableCodes.contains(error.code)
    }
}
