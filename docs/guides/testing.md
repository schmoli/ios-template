# Testing Guide

## Current Status

✅ Tests are configured and working using Swift Testing framework.

## Test Structure

```
MyAppTests/
├── AppLoggerTests.swift          # Tests for AppLogger
├── Features/
│   └── Welcome/
│       └── WelcomeViewTests.swift  # Tests for WelcomeView
└── TestHelpers/
    └── ViewTestHelpers.swift      # Shared test utilities
```

## Swift Testing Framework

This template uses Swift Testing (not XCTest):

```swift
import Testing
@testable import MyApp

@Suite("My Feature Tests")
struct MyFeatureTests {

    @Test("Feature behaves correctly")
    func testFeature() {
        let result = myFunction()
        #expect(result == expectedValue)
    }
}
```

## Running Tests

- **Xcode:** Cmd+U
- **Command Line:** `xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 17'`

## Test Examples

See existing test files for patterns:
- `AppLoggerTests.swift` - Unit testing with parameterized tests
- `WelcomeViewTests.swift` - SwiftUI view testing
- `ViewTestHelpers.swift` - Shared test utilities

## Next Steps

1. Add tests for new features as you build them
2. See `MyAppTests/Core/Networking/` for networking test patterns
