# Networking Layer

Placeholder for future async/await networking infrastructure.

## Planned Features

- Generic API client with async/await
- Request/response models
- Error handling patterns
- Authentication integration
- Request logging with AppLogger

## Usage Pattern

```swift
actor APIClient {
    private let logger = AppLogger.logger(for: .networking)

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // Implementation
    }
}
```

See `docs/patterns/networking.md` for implementation guide.
