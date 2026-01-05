# Architecture Guide

## Project Structure

```
MyApp/
├── Core/                    # Foundational systems
│   ├── Logging/            # AppLogger, LogCategory
│   ├── Networking/         # APIClient, NetworkService, retry/circuit breaking
│   ├── Security/           # SecureStorage (Keychain wrapper)
│   ├── Authentication/     # BiometricAuth (Face ID/Touch ID)
│   ├── Lifecycle/          # AppLifecycleManager (app state hooks)
│   └── Persistence/        # SwiftDataPersistence (data storage)
├── Features/               # Feature modules
│   └── Welcome/            # Welcome screen feature
│       └── Components/
├── Shared/                 # Reusable components
│   ├── Components/         # UI components (GradientBackground)
│   ├── DesignSystem/       # Design tokens (DesignConstants)
│   ├── Extensions/         # Swift extensions
│   └── Utilities/          # Helper functions
└── MyAppApp.swift          # App entry point
```

## Design Principles

### Feature-Based Organization
Each feature lives in its own directory under `Features/`. This makes it easy to:
- Find related code
- Understand feature scope
- Potentially extract features into separate modules

### Core Systems
Foundation code that features depend on goes in `Core/`:
- **Logging** - Centralized logging with AppLogger
- **Networking** - HTTP client with retry and circuit breaking
- **Security** - Keychain wrapper for secure storage
- **Authentication** - Biometric auth (Face ID/Touch ID)
- **Lifecycle** - App state change hooks
- **Persistence** - SwiftData wrapper for data storage

### Shared Code
Reusable components that don't belong to a specific feature go in `Shared/`:
- UI components
- Design system
- Extensions
- Utilities

## Adding a New Feature

1. **Create feature directory:**
```bash
mkdir -p MyApp/Features/MyFeature/Components
```

2. **Add main view:**
```swift
// MyApp/Features/MyFeature/MyFeatureView.swift
import SwiftUI

struct MyFeatureView: View {
    var body: some View {
        Text("My Feature")
    }
}
```

3. **Add to Xcode project:**
Right-click MyApp in Xcode → Add Files → Select your feature directory

## Swift 6 Strict Concurrency

This template uses Swift 6 with strict concurrency checking enabled.

### Key Guidelines:

**@MainActor for UI**
```swift
@MainActor
class MyViewModel: ObservableObject {
    @Published var data: [Item] = []
}
```

**Sendable for Shared Data**
```swift
struct UserData: Sendable {
    let id: UUID
    let name: String
}
```

**Actor for Isolated State**
```swift
actor DataCache {
    private var cache: [String: Data] = [:]

    func get(_ key: String) -> Data? {
        cache[key]
    }
}
```

## View Models with @Observable

Use `@Observable` (not `@ObservableObject`) for view models:

```swift
import SwiftUI

@Observable
@MainActor
class MyFeatureViewModel {
    var items: [Item] = []
    var isLoading = false

    func loadData() async {
        isLoading = true
        defer { isLoading = false }

        // Load data...
    }
}

struct MyFeatureView: View {
    @State private var viewModel = MyFeatureViewModel()

    var body: some View {
        List(viewModel.items) { item in
            Text(item.name)
        }
    }
}
```

## Dependency Injection

Pass dependencies explicitly rather than using singletons:

```swift
// Good
struct MyView: View {
    let apiClient: APIClient

    var body: some View {
        // Use apiClient
    }
}

// Avoid
struct MyView: View {
    var body: some View {
        // APIClient.shared - harder to test
    }
}
```

## Testing Strategy

This template uses Swift Testing framework:
- Unit tests in `MyAppTests/`
- Test helpers in `MyAppTests/TestHelpers/`
- Run with `./scripts/test.sh` or Cmd+U in Xcode
- See `docs/guides/testing.md` for patterns and examples

## Navigation Patterns

Use SwiftUI's navigation stack for feature navigation:

```swift
NavigationStack {
    FeatureListView()
        .navigationDestination(for: Feature.self) { feature in
            FeatureDetailView(feature: feature)
        }
}
```

## Error Handling

Log errors using AppLogger and provide user feedback:

```swift
do {
    try await loadData()
} catch {
    logger.error("Failed to load data: \(error)")
    // Show user-facing error
}
```

## Performance Considerations

- Use `@Observable` for fine-grained view updates
- Leverage Swift 6's actor isolation for thread safety
- Profile with Instruments before optimizing
- Use `Task` for async work, not DispatchQueue

## Core Infrastructure Available

All core infrastructure is ready to use:
- ✅ **Logging** - `docs/guides/logging.md`
- ✅ **Networking** - `docs/guides/networking.md`
- ✅ **Security** - `docs/guides/security.md`
- ✅ **Biometric Auth** - `docs/guides/biometric-auth.md`
- ✅ **Lifecycle** - `docs/guides/lifecycle.md`
- ✅ **Persistence** - `docs/guides/persistence.md`

## Next Steps

- Create feature modules in `Features/`
- Add your API clients in `Core/Networking/Clients/`
- Define your data models for SwiftData
- Build out design system in `Shared/DesignSystem/`
