# Persistence Layer

Placeholder for future SwiftData persistence infrastructure.

## Planned Features

- SwiftData model examples
- Migration patterns
- Actor-isolated data access
- Logging integration

## Usage Pattern

```swift
@Model
final class Item: Sendable {
    var id: UUID
    var name: String
    var createdAt: Date
}
```

See `docs/patterns/persistence.md` for implementation guide.
