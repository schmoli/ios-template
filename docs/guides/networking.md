# Networking Guide

The template includes a production-ready networking layer with automatic retry and circuit breaking.

## Quick Start

### 1. Create Your API Client

Create a new file in `MyApp/Core/Networking/Clients/YourAPIClient.swift`:

```swift
import Foundation

struct YourAPIClient: APIClient {
    let baseURL: URL
    let authToken: String

    func request<T: Decodable>(
        _ method: HTTPMethod,
        path: String,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return try await NetworkService.shared.execute(request)
    }
}
```

### 2. Define Response Models

```swift
struct YourResponse: Codable {
    let id: String
    let name: String
}
```

### 3. Make Requests

```swift
let client = YourAPIClient(
    baseURL: URL(string: "https://api.example.com")!,
    authToken: "your-token"
)

do {
    let response: YourResponse = try await client.request(.get, path: "/items", body: nil)
    print("Got: \(response.name)")
} catch let error as APIError {
    switch error {
    case .networkFailure(let urlError):
        // Network issue (already retried 3 times)
        print("Network failed: \(urlError)")
    case .httpError(let code, _):
        // Server returned error status
        print("Server error: \(code)")
    case .circuitBreakerOpen(let endpoint, let resetAt):
        // Endpoint is temporarily disabled
        print("\(endpoint) unavailable until \(resetAt)")
    case .decodingFailure:
        // Response format unexpected
        print("Invalid response format")
    case .invalidRequest(let message):
        // Request configuration issue
        print("Bad request: \(message)")
    }
}
```

## Features

### Automatic Retry

Network failures are automatically retried up to 3 times with exponential backoff (1s, 2s, 4s).

**Retried errors:**
- Connection lost
- Timeout
- Cannot connect to host
- Not connected to internet

**Not retried:**
- HTTP 4xx/5xx responses (application-level errors)
- Decoding failures (response format issues)

### Circuit Breaker

After 5 consecutive failures, an endpoint's circuit opens. All requests fail fast for 60 seconds, then one request is allowed to test recovery.

**Per-endpoint:** Each API host has an independent circuit. Your weather API failing won't affect your analytics API.

### Structured Errors

All failures are converted to `APIError` enum with descriptive messages:

```swift
catch let error as APIError {
    print(error.errorDescription ?? "Unknown error")
}
```

## Testing Your API Client

See `docs/examples/WeatherAPIClient.swift` for a complete example. For testing patterns, see `MyAppTests/Core/Networking/NetworkServiceTests.swift`.

### Using MockURLProtocol

```swift
@Test func testAPICall() async throws {
    MockURLProtocol.requestHandler = { request in
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        let data = try JSONEncoder().encode(YourResponse(id: "1", name: "test"))
        return (response, data)
    }

    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    let session = URLSession(configuration: config)

    let service = NetworkService(session: session)
    // Test your client...
}
```

## Architecture

- **APIClient** - Protocol your clients conform to
- **NetworkService** - Handles retry, circuit breaking, error conversion
- **CircuitBreaker** - Actor managing per-endpoint circuit state
- **RetryPolicy** - Configures retry behavior
- **APIError** - Structured error types
- **HTTPMethod** - HTTP method enum

## Logging

All network activity is logged under the `.networking` category:

```bash
# Stream network logs
log stream --predicate 'subsystem == "com.example.MyApp" AND category == "networking"' --level debug
```

## Best Practices

1. **One client per API** - Create separate clients for different backends
2. **Store clients at feature level** - Don't make them global singletons
3. **Handle errors specifically** - Match on APIError cases to provide good UX
4. **Test with MockURLProtocol** - Don't hit real APIs in tests
5. **Use #Preview for integration** - Visual verification of API-driven views

## Examples

See `docs/examples/WeatherAPIClient.swift` for a complete working example.
