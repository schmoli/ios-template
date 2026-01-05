# API Clients

Put your API client implementations here.

## Example

Each API client should:
1. Conform to `APIClient` protocol
2. Store endpoint-specific configuration (base URL, auth)
3. Implement the `request()` method
4. Delegate to `NetworkService.shared.execute()` for retry/circuit breaking

See `docs/examples/WeatherAPIClient.swift` for a complete example.

## Pattern

```swift
import Foundation

struct MyAPIClient: APIClient {
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
