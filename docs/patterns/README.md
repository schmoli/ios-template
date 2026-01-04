# Code Patterns

**TODO:** Document common code patterns as they emerge in the codebase.

## What Goes Here

Reusable code patterns and best practices specific to this template:
- Architecture patterns (MVVM, TCA, etc.)
- SwiftUI patterns (view composition, state management)
- Swift 6 concurrency patterns (@MainActor, Sendable, Actor)
- Error handling patterns
- Testing patterns

## Planned Patterns

### View Model Pattern
How to structure view models with `@Observable`:
```swift
@Observable
@MainActor
class FeatureViewModel {
    var state: FeatureState = .idle
    var items: [Item] = []

    func load() async {
        // Pattern for async loading
    }
}
```

### Repository Pattern
Abstracting data sources:
```swift
protocol UserRepository: Sendable {
    func fetchUsers() async throws -> [User]
    func save(_ user: User) async throws
}
```

### Dependency Injection
Passing dependencies explicitly:
```swift
struct FeatureView: View {
    let apiClient: APIClient
    let dataStore: DataStore

    var body: some View {
        // Use injected dependencies
    }
}
```

## When to Add Patterns

Document a pattern when:
- You've used it successfully in 2+ features
- It solves a common problem
- It's non-obvious or has subtle gotchas
- New team members would benefit from seeing it

## Format

Each pattern should include:
1. **Problem** - What problem does this solve?
2. **Solution** - How does the pattern work?
3. **Example** - Concrete code example
4. **Trade-offs** - When to use vs. alternatives
5. **See Also** - Related patterns or docs

## See Also

- Architecture Guide: `guides/architecture.md`
- Design System Guide: `guides/design-system.md`
