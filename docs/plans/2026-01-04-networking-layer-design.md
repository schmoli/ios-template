# Networking Layer Design

**Date:** 2026-01-04
**Status:** Approved
**Purpose:** Add protocol-based networking infrastructure with automatic retry and circuit breaking to the iOS template

## Overview

Add a networking layer to `Core/Networking/` that provides:
- Standardized API client protocol for features to adopt
- Automatic retry on network failures (3 attempts with exponential backoff)
- Circuit breaking to prevent hammering dead endpoints
- Structured error handling
- Testable architecture following "Prove, Don't Promise" methodology

## Architecture

The networking layer lives in `Core/Networking/` with these components:

```
Core/Networking/
├── APIClient.swift          # Protocol that features depend on
├── NetworkService.swift     # Concrete implementation with retry/circuit breaking
├── HTTPMethod.swift         # Enum: GET, POST, PUT, DELETE
├── APIError.swift           # Standardized error types
├── CircuitBreaker.swift     # Circuit breaker state machine
├── RetryPolicy.swift        # Retry configuration
└── Clients/                 # Concrete API client implementations
    └── README.md            # "Put your API clients here"
```

### Usage Pattern

When building an app from this template, add API clients to `Core/Networking/Clients/`. Example for a weather app:

```
Core/Networking/Clients/
└── WeatherAPIClient.swift   # Conforms to APIClient, talks to weather API

Features/
├── Forecast/
│   └── ForecastView.swift   # Uses WeatherAPIClient
└── Alerts/
    └── AlertsView.swift     # Also uses WeatherAPIClient
```

**Key principle:** API clients are shared infrastructure (live in `Core/Networking/Clients/`). Features consume them. Auth is client-specific, resilience is universal.

## Core Components

### APIClient Protocol

The protocol that all feature API clients conform to:

```swift
/// Protocol for making HTTP requests with automatic retry and circuit breaking.
///
/// Conform to this protocol in your feature's API client to get:
/// - Automatic retries on network failures (3 attempts with exponential backoff)
/// - Circuit breaking (stops trying after 5 consecutive failures)
/// - Structured error handling
///
/// ## Example
///
/// ```swift
/// struct WeatherAPIClient: APIClient {
///     let baseURL: URL
///     let apiKey: String
///
///     func request<T: Decodable>(
///         _ method: HTTPMethod,
///         path: String,
///         body: Encodable? = nil
///     ) async throws -> T {
///         var request = URLRequest(url: baseURL.appendingPathComponent(path))
///         request.httpMethod = method.rawValue
///         request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
///
///         return try await NetworkService.shared.execute(request)
///     }
/// }
/// ```
protocol APIClient {
    /// Make an HTTP request and decode the response.
    ///
    /// - Parameters:
    ///   - method: HTTP method (GET, POST, etc.)
    ///   - path: API endpoint path (e.g., "/api/forecast")
    ///   - body: Optional request body (will be JSON encoded)
    /// - Returns: Decoded response of type `T`
    /// - Throws: `APIError` on failure
    func request<T: Decodable>(
        _ method: HTTPMethod,
        path: String,
        body: Encodable?
    ) async throws -> T
}
```

### NetworkService

The concrete worker that handles URLSession, retries, and circuit breaking. Features don't use it directly - they go through their `APIClient` conformance.

Responsibilities:
- Execute URLRequests via URLSession
- Retry network failures per RetryPolicy
- Track circuit breaker state per endpoint
- Convert failures to structured APIError types

## Retry & Circuit Breaking

### Retry Policy

Retries happen automatically for network-level failures (timeouts, connection lost, DNS failures). **Not** for HTTP errors like 404 or 500 - those are application-level and should be handled by features.

```swift
struct RetryPolicy {
    let maxAttempts: Int = 3
    let baseDelay: TimeInterval = 1.0  // seconds

    /// Exponential backoff: 1s, 2s, 4s
    func delay(for attempt: Int) -> TimeInterval {
        return baseDelay * pow(2.0, Double(attempt - 1))
    }
}
```

**Retry triggers:**
- `URLError.networkConnectionLost`
- `URLError.timedOut`
- `URLError.cannotConnectToHost`
- `URLError.notConnectedToInternet`

**Won't retry:**
- HTTP 4xx/5xx responses (server responded, just with an error)
- Decoding failures (got data, just couldn't parse it)

### Circuit Breaker

Stops hammering a dead endpoint. After 5 consecutive failures, trips to "open" state - all requests fail fast for 60 seconds. Then tries one request (half-open). If it succeeds, circuit closes and we're back to normal.

```swift
actor CircuitBreaker {
    enum State {
        case closed       // Normal operation
        case open         // Failing fast, not trying
        case halfOpen     // Testing if recovered
    }

    private(set) var state: State = .closed
    private var consecutiveFailures = 0
    private let failureThreshold = 5
    private let resetTimeout: TimeInterval = 60.0
}
```

**Key:** Circuit breaker is per-endpoint (tracked by URL host). Different API backends have independent circuits.

## Error Handling

Structured errors that tell you exactly what went wrong and what to do about it:

```swift
/// Errors that can occur during API requests.
enum APIError: Error, LocalizedError {
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
```

**Pattern:** Features catch `APIError` and decide how to present it to users. Network failures already got retried - if you catch them, all retries failed.

## Testing Strategy

Following "Prove, Don't Promise" - tests verify the behavior:

### What to Test

**NetworkService tests:**
- ✅ Retries network failures 3 times with backoff
- ✅ Doesn't retry HTTP errors
- ✅ Circuit breaker opens after 5 failures
- ✅ Circuit breaker resets after timeout
- ✅ Successful request closes circuit

**Feature API client tests:**
- ✅ Auth headers attached correctly
- ✅ Requests formatted correctly (path, body, method)
- ✅ Responses decoded to expected models
- ✅ Errors propagate as `APIError`

### How to Test

Mock URLSession using `URLProtocol`:

```swift
final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    // Override to return canned responses
}
```

**Example test:**

```swift
@Test func retriesNetworkFailures() async throws {
    var attemptCount = 0
    MockURLProtocol.requestHandler = { _ in
        attemptCount += 1
        if attemptCount < 3 {
            throw URLError(.networkConnectionLost)
        }
        return (HTTPURLResponse(statusCode: 200), Data())
    }

    _ = try await networkService.execute(testRequest)
    #expect(attemptCount == 3)  // Proved it retried
}
```

**Verification checklist:**
- 🧪 Run tests: all pass
- 🧰 Build: succeeds
- 📱 Integration test: Make real API call in preview/simulator

## Implementation Notes

- All components use Swift 6 strict concurrency
- CircuitBreaker is an `actor` for thread-safe state management
- NetworkService uses `async/await` for clean async code
- Errors conform to `LocalizedError` for user-facing messages
- Components are logged via AppLogger with `.networking` category (to be added to LogCategory)

## Success Criteria

✅ Template builds with networking layer
✅ All NetworkService tests pass
✅ Example API client in docs can make real requests
✅ Circuit breaker demonstrably trips and recovers
✅ Retries demonstrably work with backoff
✅ App launches in simulator after adding networking layer
