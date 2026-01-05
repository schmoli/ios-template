# Infrastructure Additions Design

**Date:** 2026-01-05
**Status:** Approved for implementation

## Overview

Add four foundational infrastructure systems to the iOS template to support common app needs: data persistence, secure storage, biometric authentication, and app lifecycle management.

## Goals

- Enable rapid app development with common infrastructure patterns
- Maintain template philosophy: protocol-based, testable, YAGNI-compliant
- Follow established patterns (matches existing Networking layer)
- Support Swift 6 strict concurrency

## Non-Goals

- Domain-specific implementations (apps add their own models)
- Advanced features like CloudKit sync, backup/restore (add when needed)
- Dependency injection framework (keep simple singleton pattern)

## Design Principles

Each system follows the same pattern established by the Networking layer:

1. **Protocol** defines contract
2. **Concrete implementation** handles platform code
3. **Mock implementation** for testing
4. **Typed errors** for failure cases
5. **Actor/Sendable** for concurrency safety

## Architecture

```
Core/
├── Logging/          # ✅ Exists - AppLogger
├── Networking/       # ✅ Exists - APIClient, NetworkService
├── Persistence/      # 🆕 SwiftData wrapper
├── Security/         # 🆕 Keychain wrapper
├── Authentication/   # 🆕 Biometric auth
└── Lifecycle/        # 🆕 App state hooks
```

---

## Component 1: Persistence Layer (SwiftData)

### Purpose

Provide SwiftData-based persistence with protocol abstraction for testability and future flexibility.

### Files

```
Core/Persistence/
├── PersistenceProtocol.swift      # Storage contract
├── SwiftDataPersistence.swift     # ModelContainer wrapper
├── PersistenceError.swift         # Typed errors
└── Mocks/
    └── MockPersistence.swift      # In-memory testing
```

### API Design

```swift
protocol PersistenceProtocol: Sendable {
    var modelContainer: ModelContainer { get }
    func save() async throws
    func delete<T: PersistenceModel>(_ item: T) async throws
}

enum PersistenceError: Error {
    case saveFailed(Error)
    case deleteFailed(Error)
    case containerCreationFailed(Error)
}
```

### Implementation Details

**SwiftDataPersistence:**
- Singleton instance with shared ModelContainer
- Initializes with schema from app's @Model types
- Wraps ModelContext operations (save, delete)
- Thread-safe via actor isolation
- Configuration: in-memory for tests, file-backed for production

**MockPersistence:**
- Dictionary/array-based in-memory storage
- Implements same protocol
- No actual SwiftData dependency
- Supports rapid test iteration

### App Integration

```swift
@main
struct MyAppApp: App {
    let persistence = SwiftDataPersistence.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(persistence.modelContainer)
        }
    }
}
```

### Testing Strategy

- Unit tests: Use MockPersistence to verify business logic
- Integration tests: Use real SwiftData with in-memory configuration
- Apps add their own @Model types, template provides infrastructure

---

## Component 2: SecureStorage (Keychain)

### Purpose

Type-safe, protocol-based wrapper for storing secrets in iOS Keychain. Hides Security framework complexity.

### Files

```
Core/Security/
├── SecureStorageProtocol.swift    # Generic save/load/delete
├── KeychainSecureStorage.swift    # Keychain implementation
├── SecureStorageError.swift       # Typed errors
└── Mocks/
    └── MockSecureStorage.swift    # Dictionary-based mock
```

### API Design

```swift
protocol SecureStorageProtocol: Sendable {
    func save<T: Codable>(_ value: T, for key: String) async throws
    func load<T: Codable>(for key: String) async throws -> T?
    func delete(for key: String) async throws
    func exists(for key: String) -> Bool
}

enum SecureStorageError: Error {
    case encodingFailed(Error)
    case decodingFailed(Error)
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case notFound
}
```

### Usage Examples

```swift
// Save token
try await secureStorage.save(authToken, for: "authToken")

// Load credentials
if let creds: Credentials = try await secureStorage.load(for: "userCreds") {
    await authenticate(creds)
}

// Check existence
if secureStorage.exists(for: "authToken") {
    // Already logged in
}

// Delete on logout
try await secureStorage.delete(for: "authToken")
```

### Implementation Details

**KeychainSecureStorage:**
- Uses `kSecClassGenericPassword` for all items
- Service identifier from bundle ID (namespaces keychain items)
- JSON encoding/decoding for Codable types
- Accessibility: `kSecAttrAccessibleAfterFirstUnlock` (works in background)
- Thread-safe with actor isolation
- Proper OSStatus → typed error mapping

**MockSecureStorage:**
- Simple `[String: Data]` dictionary
- Synchronous operations (no actual keychain)
- Supports testing auth flows without keychain access

### Testing Strategy

- Mock used for all unit tests
- Real keychain only in manual/integration tests
- Apps test their auth logic with MockSecureStorage

---

## Component 3: BiometricAuth

### Purpose

Clean abstraction over LocalAuthentication framework for Face ID/Touch ID authentication.

### Files

```
Core/Authentication/
├── BiometricAuthProtocol.swift       # Auth operations
├── LocalBiometricAuth.swift          # LAContext wrapper
├── BiometricAuthError.swift          # Typed errors
├── BiometricType.swift               # faceID/touchID/none
└── Mocks/
    └── MockBiometricAuth.swift       # Configurable responses
```

### API Design

```swift
enum BiometricType: Sendable {
    case faceID
    case touchID
    case none
}

protocol BiometricAuthProtocol: Sendable {
    var biometricType: BiometricType { get async }
    var isAvailable: Bool { get async }
    func authenticate(reason: String) async throws -> Bool
}

enum BiometricAuthError: Error {
    case notAvailable
    case notEnrolled
    case userCanceled
    case authenticationFailed
    case lockout
    case systemError(Error)
}
```

### Usage Examples

```swift
// Check availability
let type = await biometricAuth.biometricType
switch type {
case .faceID: showFaceIDPrompt()
case .touchID: showTouchIDPrompt()
case .none: fallbackToPasscode()
}

// Authenticate
do {
    let success = try await biometricAuth.authenticate(
        reason: "Unlock your secure notes"
    )
    if success {
        showProtectedContent()
    }
} catch BiometricAuthError.userCanceled {
    // User tapped cancel, stay on lock screen
} catch BiometricAuthError.notAvailable {
    // Fall back to passcode
}
```

### Implementation Details

**LocalBiometricAuth:**
- Wraps `LAContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)`
- Maps `LAError` to typed `BiometricAuthError`
- Checks `context.biometryType` for Face ID vs Touch ID
- Handles "not enrolled" gracefully (returns `.none`)
- Actor-isolated for thread safety
- Reuses LAContext for performance

**MockBiometricAuth:**
- Configurable responses (success, failure, specific errors)
- No system dependency
- Test all error paths without touching biometrics

### Testing Strategy

- Mock for all unit tests (no biometric prompts during testing)
- Manual verification on device for UX
- Apps test auth flows with configurable mock responses

---

## Component 4: App Lifecycle Hooks

### Purpose

Centralized, type-safe way to observe app state changes without scattering observers throughout codebase.

### Files

```
Core/Lifecycle/
├── AppLifecycleProtocol.swift      # Hook registration
├── AppLifecycleManager.swift       # Event dispatcher
├── AppState.swift                  # active/inactive/background
└── Mocks/
    └── MockAppLifecycle.swift      # Manual event triggering
```

### API Design

```swift
enum AppState: Sendable {
    case active
    case inactive
    case background
}

protocol AppLifecycleProtocol: Sendable {
    var currentState: AppState { get }
    func onAppear(_ handler: @escaping @Sendable () async -> Void)
    func onForeground(_ handler: @escaping @Sendable () async -> Void)
    func onBackground(_ handler: @escaping @Sendable () async -> Void)
    func onInactive(_ handler: @escaping @Sendable () async -> Void)
}
```

### Usage Examples

```swift
// Register handlers during app/feature setup
lifecycle.onForeground {
    await dataService.refresh()
    await analytics.track(.appForegrounded)
}

lifecycle.onBackground {
    await stateManager.saveState()
    await networkMonitor.pause()
}

lifecycle.onInactive {
    // User pulled down notification center or took call
    videoPlayer.pause()
}
```

### Implementation Details

**AppLifecycleManager:**
- Observes SwiftUI `scenePhase` via `@Environment`
- Also observes UIKit notifications (`didEnterBackground`, etc.) as fallback
- Maintains arrays of handlers per event type
- Executes all handlers concurrently when event fires
- Actor-isolated to prevent race conditions on handler arrays
- Maps ScenePhase → AppState

**App Integration:**
```swift
@main
struct MyAppApp: App {
    let lifecycle = AppLifecycleManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) {
            lifecycle.updateState($0)
        }
    }
}
```

**MockAppLifecycle:**
- Manually trigger events: `mock.simulateForeground()`
- Verify handlers called with correct timing
- Test lifecycle-dependent logic

### Testing Strategy

- Mock for unit tests (trigger events on demand)
- Integration tests verify handler registration/execution
- Apps test their lifecycle responses with mock

---

## Testing Philosophy

All components follow the same testing approach:

| Test Type | Implementation | Purpose |
|-----------|---------------|---------|
| Unit tests | Use mocks | Verify business logic fast |
| Integration tests | Real implementations | Verify platform integration works |
| App tests | Inject mocks | Test app logic without platform dependencies |

**Example:** Testing a login feature
- Unit test: `MockSecureStorage` + `MockBiometricAuth` → verify login flow logic
- Integration test: Real keychain + real biometrics → verify platform code works
- App test: Mocks → verify UI state changes correctly

---

## Documentation Updates

### New Guides

Create `docs/guides/`:
- `persistence.md` - Using SwiftData, defining models, querying
- `security.md` - SecureStorage usage, when to use keychain
- `biometric-auth.md` - Implementing biometric flows, handling errors
- `lifecycle.md` - App lifecycle patterns, common use cases

### Update Existing

- `architecture.md` - Add new Core/ systems to architecture diagram
- `testing.md` - Document mock usage patterns
- `customization.md` - When to use each system

---

## Migration Path

Template users get these immediately. Existing apps adopting this template:

1. **Persistence:** Copy `Core/Persistence/`, add to project
2. **SecureStorage:** Copy `Core/Security/`, migrate existing keychain code
3. **BiometricAuth:** Copy `Core/Authentication/`, replace LAContext usage
4. **Lifecycle:** Copy `Core/Lifecycle/`, consolidate scattered observers

Each component is independent - adopt incrementally.

---

## Success Criteria

- ✅ All four components implemented with tests passing
- ✅ Mock implementations for each protocol
- ✅ Documentation guides written
- ✅ Example usage in template (Welcome feature or similar)
- ✅ Swift 6 strict concurrency mode enabled
- ✅ Build + tests pass
- ✅ App launches in simulator

---

## Open Questions

None - design validated with user during brainstorming.

---

## Implementation Plan

See `docs/plans/2026-01-05-infrastructure-additions-plan.md` for detailed implementation steps.
