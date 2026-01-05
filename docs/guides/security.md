# Security Guide

The template provides `SecureStorage` - a type-safe Keychain wrapper for storing sensitive data like tokens, credentials, and secrets.

## Quick Start

### 1. Store Credentials

```swift
import Foundation

// Store auth token
let secureStorage = KeychainSecureStorage.shared
try await secureStorage.save("eyJhbGc...", for: "authToken")

// Store structured data
struct Credentials: Codable, Sendable {
    let username: String
    let apiKey: String
}

let creds = Credentials(username: "user", apiKey: "key-123")
try await secureStorage.save(creds, for: "userCredentials")
```

### 2. Retrieve Data

```swift
// Load token
if let token: String = try await secureStorage.load(for: "authToken") {
    // Use token
}

// Load structured data
if let creds: Credentials = try await secureStorage.load(for: "userCredentials") {
    print("User: \(creds.username)")
}
```

### 3. Check Existence

```swift
if secureStorage.exists(for: "authToken") {
    // Already logged in
} else {
    // Show login
}
```

### 4. Delete on Logout

```swift
try await secureStorage.delete(for: "authToken")
try await secureStorage.delete(for: "userCredentials")
```

## What Gets Stored in Keychain

**DO store:**
- Authentication tokens (JWT, OAuth)
- API keys
- User credentials
- Encryption keys
- Certificates

**DON'T store:**
- Large data (>1KB) - use encrypted files instead
- Non-sensitive settings (use UserDefaults)
- Cache data (use files or in-memory)

## Error Handling

```swift
do {
    try await secureStorage.save(token, for: "authToken")
} catch SecureStorageError.encodingFailed(let message) {
    print("Failed to encode: \(message)")
} catch SecureStorageError.saveFailed(let status) {
    print("Keychain save failed: \(status)")
} catch {
    print("Unexpected error: \(error)")
}
```

### Common Errors

- **`.encodingFailed`** - Data couldn't be serialized (non-Codable type)
- **`.decodingFailed`** - Data format changed between saves
- **`.saveFailed`** - Keychain access denied (rare)
- **`.notFound`** - Key doesn't exist
- **`.loadFailed`** - Keychain read failed

## Architecture

- **`SecureStorageProtocol`** - Protocol defining storage contract
- **`KeychainSecureStorage`** - Production implementation using iOS Keychain
- **`MockSecureStorage`** - In-memory mock for testing
- **`SecureStorageError`** - Structured error types

All types are `Sendable` and thread-safe (actor-isolated).

## Testing

Use `MockSecureStorage` in tests:

```swift
import Testing

@Test func testLogin() async throws {
    let storage = MockSecureStorage()

    // Simulate saved token
    try await storage.save("test-token", for: "authToken")

    // Test feature that loads token
    let feature = LoginFeature(secureStorage: storage)
    let isLoggedIn = await feature.checkAuth()

    #expect(isLoggedIn == true)
}
```

## Implementation Details

**Accessibility**: `kSecAttrAccessibleAfterFirstUnlock`
- Items accessible once device unlocked
- Works in background
- More secure than `.always`

**Service Identifier**: Bundle ID (`com.example.MyApp`)
- Namespaces your keychain items
- Won't conflict with other apps

**Encoding**: JSON via `JSONEncoder`
- Any `Codable` type works
- Handles nested structures

## Best Practices

### Do:
- Store only sensitive data
- Delete tokens on logout
- Use structured types (not just strings)
- Check `exists()` before expensive operations
- Handle errors gracefully

### Don't:
- Store large blobs (>1KB)
- Store non-sensitive data
- Ignore decoding errors (might indicate data migration needed)
- Share keys across unrelated features
- Store debug/development secrets in production builds

## Migration Pattern

When your data model changes:

```swift
// Try new format
if let newCreds: CredentialsV2 = try? await storage.load(for: "credentials") {
    return newCreds
}

// Fall back to old format
if let oldCreds: CredentialsV1 = try? await storage.load(for: "credentials") {
    let migrated = CredentialsV2(from: oldCreds)
    try await storage.save(migrated, for: "credentials")
    return migrated
}

// No credentials
return nil
```

## Example: Auth Flow

```swift
actor AuthManager {
    private let storage: SecureStorageProtocol

    init(storage: SecureStorageProtocol = KeychainSecureStorage.shared) {
        self.storage = storage
    }

    func login(username: String, password: String) async throws {
        let token = try await apiClient.authenticate(username, password)
        try await storage.save(token, for: "authToken")
    }

    func logout() async throws {
        try await storage.delete(for: "authToken")
    }

    func isAuthenticated() -> Bool {
        storage.exists(for: "authToken")
    }

    func getToken() async throws -> String? {
        try await storage.load(for: "authToken")
    }
}
```

## See Also

- **Biometric Auth** - `docs/guides/biometric-auth.md` - Protect keychain access with Face ID
- **Networking** - `docs/guides/networking.md` - Using stored tokens in API requests
