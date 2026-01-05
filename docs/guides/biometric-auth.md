# Biometric Authentication Guide

The template provides `BiometricAuth` - a clean wrapper over LocalAuthentication for Face ID, Touch ID, and Optic ID authentication.

## Quick Start

### 1. Check Biometric Type

```swift
let biometricAuth = LocalBiometricAuth.shared

let type = await biometricAuth.biometricType
switch type {
case .faceID:
    print("Device has Face ID")
case .touchID:
    print("Device has Touch ID")
case .none:
    print("No biometrics available")
}
```

### 2. Authenticate User

```swift
do {
    let success = try await biometricAuth.authenticate(
        reason: "Unlock your secure notes"
    )

    if success {
        // Show protected content
        showSecureContent()
    }
} catch BiometricAuthError.userCanceled {
    // User tapped Cancel
    print("Authentication canceled")
} catch BiometricAuthError.notAvailable {
    // Fall back to passcode
    showPasscodeEntry()
} catch {
    print("Authentication failed: \(error)")
}
```

### 3. Check Availability

```swift
if await biometricAuth.isAvailable {
    // Show biometric option
} else {
    // Show passcode-only flow
}
```

## Common Patterns

### Lock Screen with Biometric Unlock

```swift
struct SecureView: View {
    @State private var isUnlocked = false
    let biometricAuth = LocalBiometricAuth.shared

    var body: some View {
        Group {
            if isUnlocked {
                SecureContentView()
            } else {
                LockScreen()
                    .task {
                        await attemptUnlock()
                    }
            }
        }
    }

    func attemptUnlock() async {
        guard await biometricAuth.isAvailable else {
            // No biometrics - show passcode
            return
        }

        do {
            isUnlocked = try await biometricAuth.authenticate(
                reason: "Access your secure data"
            )
        } catch {
            // Show error or passcode fallback
        }
    }
}
```

### Protecting Sensitive Actions

```swift
func deleteAccount() async {
    do {
        let confirmed = try await biometricAuth.authenticate(
            reason: "Confirm account deletion"
        )

        if confirmed {
            await performDeletion()
        }
    } catch {
        showError("Cannot delete without authentication")
    }
}
```

### Adaptive UI Based on Biometric Type

```swift
struct SettingsView: View {
    @State private var biometricType: BiometricType = .none
    let biometricAuth = LocalBiometricAuth.shared

    var body: some View {
        List {
            Section {
                Toggle(biometricLabel, isOn: $biometricEnabled)
            } header: {
                Text("Security")
            }
        }
        .task {
            biometricType = await biometricAuth.biometricType
        }
    }

    var biometricLabel: String {
        switch biometricType {
        case .faceID: return "Require Face ID"
        case .touchID: return "Require Touch ID"
        case .none: return "Require Authentication"
        }
    }
}
```

## Error Handling

### All Error Cases

```swift
do {
    try await biometricAuth.authenticate(reason: "Unlock app")
} catch BiometricAuthError.notAvailable {
    // Biometrics not supported on device
    fallbackToPasscode()
} catch BiometricAuthError.notEnrolled {
    // User hasn't set up Face ID/Touch ID
    promptToEnableBiometrics()
} catch BiometricAuthError.userCanceled {
    // User tapped Cancel button
    // Stay on lock screen
} catch BiometricAuthError.authenticationFailed {
    // Face/fingerprint not recognized (after multiple attempts)
    showAuthFailedMessage()
} catch BiometricAuthError.lockout {
    // Too many failed attempts
    showLockoutMessage()
} catch BiometricAuthError.systemError(let message) {
    // Unexpected system error
    print("System error: \(message)")
}
```

### Graceful Degradation

```swift
func authenticateUser() async -> Bool {
    guard await biometricAuth.isAvailable else {
        // No biometrics - fall back to passcode
        return await authenticateWithPasscode()
    }

    do {
        return try await biometricAuth.authenticate(
            reason: "Access your account"
        )
    } catch BiometricAuthError.userCanceled {
        // User explicitly canceled
        return false
    } catch {
        // Any other error - offer passcode fallback
        return await authenticateWithPasscode()
    }
}
```

## Privacy Configuration

**Required:** Face ID usage description is already configured in the Xcode project build settings.

The template includes this privacy key:
```
INFOPLIST_KEY_NSFaceIDUsageDescription = "MyApp uses Face ID to securely access your data"
```

**After running `setup.sh`**, the message will automatically update to use your app name.

**To customize the message:**
1. Open your Xcode project
2. Select the app target
3. Go to Build Settings tab
4. Search for "NSFaceIDUsageDescription"
5. Update the value to your preferred message

Without this privacy key, biometric authentication will fail with a system error.

## Architecture

- **`BiometricAuthProtocol`** - Protocol defining auth contract
- **`LocalBiometricAuth`** - Production implementation using LocalAuthentication
- **`MockBiometricAuth`** - Configurable mock for testing
- **`BiometricType`** - Enum for device capability
- **`BiometricAuthError`** - Structured error types

All types are `Sendable` and thread-safe (actor-isolated).

## Testing

Use `MockBiometricAuth` in tests:

```swift
import Testing

@Test func testBiometricUnlock() async throws {
    let mockAuth = MockBiometricAuth()
    mockAuth.configure(biometricType: .faceID, isAvailable: true)

    let view = SecureView(biometricAuth: mockAuth)

    // Simulate successful auth
    let result = try await mockAuth.authenticate(reason: "Test")
    #expect(result == true)
}

@Test func testUserCanceled() async throws {
    let mockAuth = MockBiometricAuth()
    mockAuth.setError(.userCanceled)

    do {
        _ = try await mockAuth.authenticate(reason: "Test")
        Issue.record("Should have thrown")
    } catch let error as BiometricAuthError {
        #expect(error == .userCanceled)
    }
}
```

## Best Practices

### Do:
- Provide clear, specific reasons ("Unlock your messages", not "Authenticate")
- Always have passcode fallback
- Handle `.userCanceled` gracefully (don't show error)
- Check `isAvailable` before showing biometric UI
- Use appropriate UI for biometric type (Face ID vs Touch ID icons)

### Don't:
- Force biometric auth without fallback
- Show error for user cancellation
- Call `authenticate()` in tight loops
- Assume biometrics are available
- Use vague reason strings ("Security check")

## Example: Complete Auth Flow

```swift
actor AuthenticationManager {
    private let biometricAuth: BiometricAuthProtocol
    private let secureStorage: SecureStorageProtocol
    private(set) var isAuthenticated = false

    init(
        biometricAuth: BiometricAuthProtocol = LocalBiometricAuth.shared,
        secureStorage: SecureStorageProtocol = KeychainSecureStorage.shared
    ) {
        self.biometricAuth = biometricAuth
        self.secureStorage = secureStorage
    }

    func requireAuthentication() async throws {
        // Check if token exists
        guard secureStorage.exists(for: "authToken") else {
            throw AuthError.notLoggedIn
        }

        // Already authenticated this session
        if isAuthenticated {
            return
        }

        // Try biometric auth
        if await biometricAuth.isAvailable {
            do {
                let success = try await biometricAuth.authenticate(
                    reason: "Access your account"
                )
                isAuthenticated = success
                if !success {
                    throw AuthError.authenticationFailed
                }
            } catch BiometricAuthError.userCanceled {
                throw AuthError.userCanceled
            } catch {
                // Biometric failed - could offer passcode fallback here
                throw AuthError.authenticationFailed
            }
        } else {
            // No biometrics - implement passcode check
            throw AuthError.biometricsNotAvailable
        }
    }

    func logout() {
        isAuthenticated = false
    }
}

enum AuthError: Error {
    case notLoggedIn
    case authenticationFailed
    case userCanceled
    case biometricsNotAvailable
}
```

## Platform Support

- **Face ID**: iPhone X and later, iPad Pro (2018+)
- **Touch ID**: iPhone 5s - 8/SE, iPad Air 2+, MacBook Pro with Touch Bar
- **Optic ID**: Apple Vision Pro

The API handles all biometric types transparently.

## See Also

- **Security** - `docs/guides/security.md` - Storing auth tokens securely
- **Lifecycle** - `docs/guides/lifecycle.md` - Re-authenticate on app foreground
