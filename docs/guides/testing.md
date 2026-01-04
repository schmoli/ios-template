# Testing Guide

> **TODO:** Test infrastructure needs manual configuration in Xcode

## Current Status

This template includes test file structure but requires manual setup:

- ✅ Test files created in `MyAppTests/`
- ✅ Test helpers in `MyAppTests/TestHelpers/`
- ❌ Test target needs configuration in Xcode

## Manual Setup Required

1. **Configure Test Target in Xcode:**
   - Open `MyApp.xcodeproj`
   - Select MyAppTests target
   - Set "Host Application" to "MyApp"
   - Ensure Swift Version is 6.0
   - Enable "Generate Info.plist File"

2. **Fix Module Imports:**
   The test files use `@testable import MyApp` which requires additional configuration for iOS app targets.

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

Once configured:
- **Xcode:** Cmd+U
- **Command Line:** `xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 17'`

## Test Examples

See existing test files for patterns:
- `AppLoggerTests.swift` - Unit testing with parameterized tests
- `WelcomeViewTests.swift` - SwiftUI view testing
- `ViewTestHelpers.swift` - Shared test utilities

## Next Steps

1. Complete test target configuration in Xcode
2. Verify tests build and run
3. Add tests for new features as you build them
4. Update this guide with working examples
