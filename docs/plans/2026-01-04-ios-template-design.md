# iOS Project Template - Modern Swift 6 Design

**Date:** 2026-01-04
**Status:** Approved
**Target:** iOS 26+, Swift 6.0, SwiftUI

## Overview

Transform the existing MyApp scaffold into a production-ready iOS project template with:
- Standardized logging infrastructure
- Modern Swift Testing framework with SwiftUI view testing
- Feature-based project organization
- Comprehensive documentation
- Strict Swift 6 concurrency from the start
- CLI-first development workflow
- Automated template customization

## Design Principles

1. **Batteries included, opinions light** - Provide working examples without forcing architectural choices
2. **YAGNI ruthlessly** - Only include what every project needs, document extensions
3. **Swift 6 native** - Complete concurrency checking, modern patterns throughout
4. **CLI-first** - Everything works via command line, no Xcode IDE required
5. **Example-driven** - Show patterns through working code, not just documentation

---

## Architecture

### Top-Level Structure

```
MyApp/
├── Core/              # Cross-feature infrastructure
│   ├── Logging/       # Standardized Logger wrapper
│   ├── Networking/    # (future) async/await API client
│   └── Persistence/   # (future) SwiftData patterns
├── Features/          # Feature modules
│   └── Welcome/       # Example feature (current ContentView)
├── Shared/            # Cross-feature utilities
│   ├── Components/    # Reusable UI components
│   ├── Extensions/    # Swift/SwiftUI extensions
│   └── DesignSystem/  # Colors, spacing, typography
└── MyAppApp.swift     # App entry point
```

### Test Structure

```
MyAppTests/           # Unit tests (Swift Testing)
├── Core/
├── Features/
└── Shared/

MyAppUITests/         # UI tests (Swift Testing + SwiftUI)
└── Scenarios/
```

### Philosophy

- **Feature-based organization** scales from small apps to large projects
- Each feature is self-contained with views, view models, and feature-specific components
- Core/ provides shared infrastructure used across features
- Shared/ contains utilities and UI components used by multiple features
- Tests mirror production structure for easy navigation

---

## Core Logging Infrastructure

### Design

Standardize `os.log` usage without overengineering. Create `Core/Logging/AppLogger.swift` with:

1. **Centralized subsystem constant** - Single source of truth for bundle identifier
2. **Category enum** - Type-safe logging categories (startup, networking, ui, data, etc.)
3. **Logger factory** - Consistent creation: `AppLogger.logger(for: .networking)`
4. **Privacy helpers** - Extension methods for common privacy levels

### Implementation

**File: `Core/Logging/LogCategory.swift`**
```swift
enum LogCategory: String {
    case startup
    case networking
    case ui
    case data
    case auth
    case general
}
```

**File: `Core/Logging/AppLogger.swift`**
```swift
import os.log

enum AppLogger {
    // Centralized subsystem - update when customizing template
    static let subsystem = "com.example.MyApp"

    // Logger factory
    static func logger(for category: LogCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }
}

// Privacy convenience extensions
extension Logger {
    func debug(_ message: String, privacy: OSLogPrivacy = .auto) {
        // Implementation
    }
}
```

### Swift 6 Concurrency

- Logger is Sendable - works with actors and async contexts
- No global state - factory pattern creates isolated loggers
- Thread-safe by default through os.log

### Usage Pattern

```swift
private let logger = AppLogger.logger(for: .networking)

func fetchData() async throws {
    logger.debug("Starting fetch...")
    // ... implementation
    logger.info("Fetch completed: \(count) items")
}
```

### Documentation

`docs/guides/logging.md` explains:
- How to use AppLogger
- Examples for common scenarios (startup, errors, user actions, performance)
- Privacy best practices
- When to use each log level

---

## Testing Infrastructure

### Approach

Use **Swift Testing framework** (Xcode 16+) with SwiftUI-native testing patterns. Provide working examples that demonstrate best practices.

### Unit Testing (MyAppTests/)

Uses `@Test` macro instead of XCTest. Demonstrates:

1. **Testing async functions** - `@Test func fetchData() async throws`
2. **Parameterized tests** - `@Test(arguments: [cases]) func validate(input:)`
3. **Testing SwiftUI views directly** - In-process view testing
4. **Testing actors and MainActor isolation** - Modern concurrency patterns

**Structure:**
```
MyAppTests/
├── Core/
│   └── Logging/
│       └── AppLoggerTests.swift       // Verify logger factory
├── Features/
│   └── Welcome/
│       ├── WelcomeViewTests.swift      // SwiftUI view tests
│       └── WelcomeViewModelTests.swift // Logic tests
└── TestHelpers/
    └── ViewTestHelpers.swift           // Shared utilities
```

### SwiftUI View Testing

Test views directly with Swift Testing:
```swift
@Test func welcomeViewDisplaysCorrectly() {
    let view = WelcomeView()
    // Test view hierarchy, bindings, state changes
}
```

### CLI Testing

Runnable via:
```bash
swift test
# or
xcodebuild test -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 17'
```

### Documentation

`docs/guides/testing.md` covers:
- Swift Testing basics (@Test, @Suite, async tests)
- SwiftUI view testing patterns
- Testing actors and concurrency
- Running tests from CLI
- Parameterized test examples

---

## Feature-Based Project Structure

### Feature Anatomy

Each feature is self-contained within Features/ directory:

```
Features/
└── Welcome/
    ├── WelcomeView.swift           // Main view
    ├── WelcomeViewModel.swift      // @Observable view model
    ├── Components/                 // Feature-specific components
    │   └── WelcomeCard.swift
    └── README.md                   // Feature documentation
```

### Core/ Directory

```
Core/
├── Logging/
│   ├── AppLogger.swift            // Logger factory
│   └── LogCategory.swift          // Category enum
├── Networking/                     // (Future expansion)
│   └── README.md                  // Placeholder with patterns
└── Persistence/                    // (Future expansion)
    └── README.md                  // SwiftData patterns
```

### Shared/ Directory

```
Shared/
├── Components/                     // Cross-feature UI
│   └── GradientBackground.swift
├── Extensions/
│   ├── View+Extensions.swift
│   └── Color+Extensions.swift
├── DesignSystem/
│   ├── DesignConstants.swift      // Expanded from current
│   ├── Typography.swift           // Font styles
│   └── Spacing.swift              // Layout constants
└── Utilities/
    └── (future helpers)
```

### Organization Principles

- All types Sendable by default
- View models use `@Observable` (not `@ObservableObject`)
- Actor-isolated state in dedicated files
- Each feature has README explaining purpose and usage

---

## Documentation Structure

### Hierarchy

```
docs/
├── README.md                       // Index to all docs
├── guides/
│   ├── logging.md                 // How to use AppLogger
│   ├── testing.md                 // Testing patterns & examples
│   ├── architecture.md            // Feature organization
│   ├── swift6-concurrency.md      // Actor patterns, Sendable
│   ├── adding-features.md         // Step-by-step feature creation
│   └── customizing-template.md    // Template customization guide
├── patterns/
│   ├── view-models.md             // @Observable patterns
│   ├── navigation.md              // SwiftUI navigation
│   └── error-handling.md          // Result types, error logging
└── plans/                          // Design documents
    └── 2026-01-04-ios-template-design.md
```

### Inline Documentation Standards

- All public types have doc comments
- Complex functions include usage examples
- Protocols document conformance requirements
- Use `///` with proper markup (parameters, returns, throws)

### README.md Strategy

- Keep comprehensive CLI command reference
- Add "Quick Start" section at top
- Link to docs/ for detailed guides
- Maintain CLI-first workflow prominence

---

## Swift 6 Concurrency Configuration

### Project Settings

- **Swift Language Version:** 6.0
- **Swift Concurrency Checking:** Complete
- **Enable Actor Data-Race Safety:** Yes
- **Strict Concurrency:** Minimal (for dependencies not Swift 6 ready)

### Patterns Demonstrated

**1. @Observable view models:**
```swift
@Observable
@MainActor
final class WelcomeViewModel {
    var message: String = ""

    func load() async {
        // MainActor-isolated by default
    }
}
```

**2. Actor-based services:**
```swift
actor DataCache {
    private var cache: [String: Data] = [:]

    func get(_ key: String) -> Data? { cache[key] }
}
```

**3. Sendable types everywhere** - All models conform to Sendable

**4. Structured concurrency** - TaskGroup examples in networking layer

### Template Verification

Includes compile-time test that fails if concurrency checking isn't properly configured. Ensures every clone maintains strict concurrency.

### Documentation

`docs/guides/swift6-concurrency.md` explains:
- Actor isolation fundamentals
- @MainActor usage patterns
- Sendable requirements
- Common patterns for converting Swift 5 code
- Troubleshooting concurrency errors

---

## Build Configuration

### Build Configurations

- **Debug:** Fast compilation, full symbols, disabled optimizations
- **Release:** Aggressive optimizations, stripped symbols
- **(Future) Staging:** Release optimizations with debug logging

### Security Settings

- Enable Hardened Runtime
- Code signing configured for development team
- Keychain access groups properly scoped
- Transport security allows HTTPS only

### Performance Settings

- Whole Module Optimization (Release)
- Link-Time Optimization enabled
- Dead code stripping enabled
- Compiler optimization: -O for Release

### CLI Scripts

The `scripts/` directory includes:
- `build.sh` - Standard debug build
- `test.sh` - Run all tests with simulator setup
- `install.sh` - Build, install, launch on simulator
- `bootstrap.sh` - First-time setup (simulators, Xcode validation)

### Configuration Files

Uses `.xcconfig` files for build settings:
- `Configuration/Development.xcconfig` - Team ID, Bundle ID
- `Configuration/Release.xcconfig` - Release-specific settings

Makes customization clearer and version-controllable.

---

## Template Customization & Setup

### Setup Script

```bash
./setup.sh --name "CoolApp" --bundle-id "com.company.coolapp" --team-id "ABC123XYZ"
```

### Automation

**What it does:**
1. Rename project files (MyApp.xcodeproj → CoolApp.xcodeproj)
2. Update all code references (imports, subsystem strings, logger categories)
3. Replace bundle identifier (project.pbxproj, Info.plist)
4. Update team ID (code signing)
5. Rename main app struct (MyAppApp → CoolAppApp)
6. Update documentation (READMEs, guides)
7. Initialize fresh git repo (optional flag)

### Validation

After customization, runs build to verify:
- All references updated correctly
- Project compiles without errors
- Tests pass

### Manual Steps

`docs/guides/customizing-template.md` includes checklist for items script can't automate:
- App icon replacement
- Accent color customization
- Display name localization
- Custom build configurations

### GitHub Template

Includes `.github/` configuration for "Use this template" button. Users click, clone, run `./setup.sh`.

---

## Project Hygiene & CI/CD

### .gitignore Enhancements

```gitignore
# Xcode
build/
*.xcuserstate
xcuserdata/
DerivedData/
*.moved-aside
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.swiftpm/
Packages/
*.xcworkspace

# CI/CD artifacts
fastlane/report.xml
fastlane/screenshots/
coverage/

# Environment secrets
.env
Config.xcconfig
```

### GitHub Actions Placeholder

`.github/workflows/ci.yml` (commented out initially):
- Runs on PR and main branch
- Swift 6 compilation with strict concurrency
- Full test suite (unit + SwiftUI tests)
- Builds for multiple iOS versions
- Test coverage report

Developers enable as needed.

### Code Quality Tools (Optional)

- **SwiftLint:** `.swiftlint.yml` with Swift 6-friendly rules
- **SwiftFormat:** Consistent style configuration
- Both disabled by default, documented how to enable

### Dependency Management

Empty `Package.swift` placeholder showing how to add SPM dependencies while maintaining Swift 6 concurrency guarantees.

---

## Implementation Phases

### Phase 1: Core Infrastructure
1. Create feature-based folder structure
2. Implement Core/Logging system
3. Update .gitignore
4. Migrate existing files to new structure

### Phase 2: Testing Framework
1. Add Swift Testing test targets
2. Create example tests (AppLogger, WelcomeView)
3. Add test helpers
4. Create testing documentation

### Phase 3: Documentation
1. Create docs/ structure
2. Write comprehensive guides
3. Update README with Quick Start
4. Document all patterns

### Phase 4: Build & Tooling
1. Create .xcconfig files
2. Write CLI scripts (build, test, install, bootstrap)
3. Configure Swift 6 concurrency settings
4. Add GitHub Actions placeholder

### Phase 5: Template Automation
1. Write setup.sh customization script
2. Add validation build step
3. Create customization guide
4. Configure as GitHub template

### Phase 6: Polish
1. Expand DesignSystem with Typography, Spacing
2. Add View/Color extensions
3. Create comprehensive examples
4. Final documentation review

---

## Success Criteria

- [ ] All code compiles with Swift 6 complete concurrency checking
- [ ] All tests pass via CLI (`swift test`)
- [ ] Template can be customized via `./setup.sh` in <2 minutes
- [ ] Documentation is comprehensive and clear
- [ ] Project builds and runs via CLI without Xcode IDE
- [ ] Feature-based structure demonstrated with working example
- [ ] Logging infrastructure used throughout codebase
- [ ] Swift Testing examples cover common patterns

---

## Future Enhancements (Not in Initial Template)

Document in READMEs but don't implement:
- Networking layer with async/await
- SwiftData persistence patterns
- Navigation architecture
- Dependency injection
- Analytics/crash reporting
- Fastlane integration
- DocC documentation generation

Keep template focused on essentials, provide clear paths to add these later.

---

## Notes

- Prioritize simplicity over completeness
- Every feature should have a clear example
- Documentation explains "why" not just "what"
- CLI-first ensures agent compatibility
- Swift 6 strictness catches issues early
- Template should feel modern, not over-engineered
