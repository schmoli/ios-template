import Foundation

/// Errors that can occur during API requests.
enum APIError: Error, LocalizedError, Sendable {
    /// Network-level failure (no internet, timeout, etc.)
    /// - Automatically retried up to 3 times
    case networkFailure(URLError)

    /// Circuit breaker is open - endpoint is temporarily disabled
    /// - Wait and try again later
    case circuitBreakerOpen(endpoint: String, resetAt: Date)

    /// Server returned HTTP error status
    /// - Not retried - handle in your feature code
    case httpError(statusCode: Int, data: Data?)

    /// Response couldn't be decoded
    /// - Not retried - usually means API contract changed
    case decodingFailure(DecodingError)

    /// Request invalid (bad URL, etc.)
    case invalidRequest(String)

    var errorDescription: String? {
        switch self {
        case .networkFailure(let error):
            return "Network error: \(error.localizedDescription)"
        case .circuitBreakerOpen(let endpoint, let resetAt):
            return "Service \(endpoint) temporarily unavailable until \(resetAt)"
        case .httpError(let code, _):
            return "Server error: HTTP \(code)"
        case .decodingFailure:
            return "Response format invalid"
        case .invalidRequest(let msg):
            return "Invalid request: \(msg)"
        }
    }
}
