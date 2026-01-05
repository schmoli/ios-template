# App Lifecycle Guide

The template provides `AppLifecycleManager` - centralized hooks for app state changes, eliminating scattered `scenePhase` observers.

## Quick Start

### 1. Wire Up in App Entry Point

```swift
import SwiftUI

@main
struct MyAppApp: App {
    let lifecycle = AppLifecycleManager.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) { _, newPhase in
            lifecycle.updateState(newPhase)
        }
    }
}
```

### 2. Register Handlers

```swift
// In your feature setup or view model
let lifecycle = AppLifecycleManager.shared

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

lifecycle.onAppear {
    // First time app becomes visible this session
    await startupService.initialize()
}
```

## App States

### `.active`
App is in foreground and receiving events. Normal operating state.

### `.inactive`
App is visible but not receiving events. Happens when:
- User pulls down notification center
- Incoming call
- Face ID prompt shown
- App switching animation

### `.background`
App is not visible. Happens when:
- User switches to another app
- Device locked
- User goes to home screen

## Common Patterns

### Auto-Refresh on Foreground

```swift
actor DataManager {
    init(lifecycle: AppLifecycleProtocol = AppLifecycleManager.shared) {
        lifecycle.onForeground {
            await self.refreshIfStale()
        }
    }

    func refreshIfStale() async {
        guard needsRefresh else { return }
        await fetchLatestData()
    }
}
```

### Pause/Resume Operations

```swift
actor MediaPlayer {
    private var isPlaying = false

    init(lifecycle: AppLifecycleProtocol = AppLifecycleManager.shared) {
        lifecycle.onInactive {
            await self.pause()
        }

        lifecycle.onForeground {
            await self.resumeIfNeeded()
        }
    }

    func pause() {
        isPlaying = false
        // Stop playback
    }

    func resumeIfNeeded() {
        // Resume if was playing
    }
}
```

### Save State on Background

```swift
actor AppStateManager {
    init(lifecycle: AppLifecycleProtocol = AppLifecycleManager.shared) {
        lifecycle.onBackground {
            await self.saveState()
        }
    }

    func saveState() async {
        // Persist current state
        try? await persistence.save()
    }
}
```

### One-Time Initialization

```swift
actor StartupManager {
    private var hasInitialized = false

    init(lifecycle: AppLifecycleProtocol = AppLifecycleManager.shared) {
        lifecycle.onAppear {
            await self.initializeOnce()
        }
    }

    func initializeOnce() async {
        guard !hasInitialized else { return }
        hasInitialized = true

        // Expensive startup tasks
        await loadConfiguration()
        await warmUpCaches()
    }
}
```

### Re-authentication on Foreground

```swift
actor SecurityManager {
    private let biometricAuth: BiometricAuthProtocol
    private var isAuthenticated = false

    init(
        lifecycle: AppLifecycleProtocol = AppLifecycleManager.shared,
        biometricAuth: BiometricAuthProtocol = LocalBiometricAuth.shared
    ) {
        self.biometricAuth = biometricAuth

        lifecycle.onForeground {
            await self.requireReauthentication()
        }

        lifecycle.onBackground {
            await self.clearAuthentication()
        }
    }

    func requireReauthentication() async {
        isAuthenticated = false
        // Trigger lock screen
    }

    func clearAuthentication() {
        isAuthenticated = false
    }
}
```

## Handler Execution

**Parallel by default:** All handlers for an event run concurrently.

```swift
// These run in parallel
lifecycle.onForeground { await taskA() }
lifecycle.onForeground { await taskB() }
lifecycle.onForeground { await taskC() }
```

**Sequential if needed:** Use your own coordination:

```swift
actor SequentialCoordinator {
    func handleForeground() async {
        await step1()
        await step2()
        await step3()
    }
}

let coordinator = SequentialCoordinator()
lifecycle.onForeground {
    await coordinator.handleForeground()
}
```

## State Transitions

```
Active → Inactive → Background → Inactive → Active
  ↑                                            ↓
  └──────────────── (resume) ─────────────────┘
```

**Typical flow:**
1. App launches → `onAppear` fires once
2. User switches away → `inactive` → `background` → `onBackground` fires
3. User returns → `inactive` → `active` → `onForeground` fires
4. Notification shown → `inactive` → `onInactive` fires
5. Notification dismissed → `active`

## Architecture

- **`AppLifecycleProtocol`** - Protocol defining hook registration
- **`AppLifecycleManager`** - Concrete implementation managing handlers
- **`AppState`** - Enum for current state
- **`MockAppLifecycle`** - Mock for testing with manual state simulation

All types are `Sendable` and thread-safe (actor-isolated).

## Testing

Use `MockAppLifecycle` in tests:

```swift
import Testing

@Test func testRefreshOnForeground() async throws {
    let mockLifecycle = MockAppLifecycle()
    let manager = DataManager(lifecycle: mockLifecycle)

    // Simulate app going to foreground
    await mockLifecycle.simulateForeground()

    // Verify refresh happened
    let lastRefresh = await manager.lastRefreshTime
    #expect(lastRefresh != nil)
}

@Test func testStatePreservation() async throws {
    let mockLifecycle = MockAppLifecycle()
    let stateManager = AppStateManager(lifecycle: mockLifecycle)

    // User does work
    await stateManager.updateState("important data")

    // App backgrounds
    await mockLifecycle.simulateBackground()

    // Verify state was saved
    let saved = await stateManager.savedState
    #expect(saved == "important data")
}
```

## Best Practices

### Do:
- Register handlers during initialization (not in `body`)
- Use actors to coordinate state changes
- Make handlers idempotent (safe to call multiple times)
- Keep handlers fast (<100ms if possible)
- Clean up resources in background handlers

### Don't:
- Register handlers in SwiftUI `body` (causes memory leaks)
- Do heavy work in inactive handlers (short window)
- Assume specific transition order
- Block main thread in handlers
- Forget that handlers run in parallel

## Example: Complete Feature Setup

```swift
actor AppCoordinator {
    private let dataManager: DataManager
    private let authManager: AuthManager
    private let analyticsManager: AnalyticsManager

    init(lifecycle: AppLifecycleProtocol = AppLifecycleManager.shared) {
        self.dataManager = DataManager()
        self.authManager = AuthManager()
        self.analyticsManager = AnalyticsManager()

        // First launch
        lifecycle.onAppear {
            await self.handleAppear()
        }

        // Returning to foreground
        lifecycle.onForeground {
            await self.handleForeground()
        }

        // Going to background
        lifecycle.onBackground {
            await self.handleBackground()
        }

        // Interrupted (call, notification center, etc)
        lifecycle.onInactive {
            await self.handleInactive()
        }
    }

    func handleAppear() async {
        // One-time setup
        await dataManager.initialize()
        await analyticsManager.trackLaunch()
    }

    func handleForeground() async {
        // Refresh data
        await dataManager.refresh()

        // Re-authenticate if needed
        if await authManager.requiresReauth {
            await authManager.authenticate()
        }

        // Track engagement
        await analyticsManager.trackForeground()
    }

    func handleBackground() async {
        // Save state
        await dataManager.saveState()

        // Clear sensitive data
        await authManager.clearSession()

        // Stop timers
        await analyticsManager.stopTracking()
    }

    func handleInactive() {
        // Pause playback, hide sensitive UI
    }
}

// In app entry point:
@main
struct MyAppApp: App {
    let coordinator = AppCoordinator()
    // lifecycle.updateState wiring shown above
}
```

## Performance Notes

- Handlers are called on background thread (async)
- Multiple handlers run concurrently
- State updates are serialized via actor
- Background time is limited (~30s) - be quick

## See Also

- **Security** - `docs/guides/security.md` - Clear tokens on background
- **Biometric Auth** - `docs/guides/biometric-auth.md` - Re-auth on foreground
- **Persistence** - `docs/guides/persistence.md` - Save state on background
