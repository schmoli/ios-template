# iOS Template Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Transform MyApp scaffold into production-ready iOS template with logging, testing, docs, and automation.

**Architecture:** Feature-based organization with Core/ (logging, infrastructure), Features/ (self-contained modules), Shared/ (cross-feature utilities). Swift 6 strict concurrency throughout.

**Tech Stack:** Swift 6.0, SwiftUI, Swift Testing, os.log, xcodebuild CLI, bash scripts

---

## Phase 1: Core Infrastructure

### Task 1: Update .gitignore

**Files:**
- Modify: `.gitignore`

**Step 1: Add template-specific ignores**

Add to `.gitignore`:
```gitignore
# Xcode (enhanced)
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

**Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: enhance .gitignore for template"
```

---

### Task 2: Create Core Directory Structure

**Files:**
- Create: `MyApp/Core/Logging/.gitkeep`
- Create: `MyApp/Core/Networking/README.md`
- Create: `MyApp/Core/Persistence/README.md`

**Step 1: Create Core/Logging directory**

```bash
mkdir -p MyApp/Core/Logging
touch MyApp/Core/Logging/.gitkeep
```

**Step 2: Create Core/Networking placeholder**

```bash
mkdir -p MyApp/Core/Networking
```

Create `MyApp/Core/Networking/README.md`:
```markdown
# Networking Layer

Placeholder for future async/await networking infrastructure.

## Planned Features

- Generic API client with async/await
- Request/response models
- Error handling patterns
- Authentication integration
- Request logging with AppLogger

## Usage Pattern

```swift
actor APIClient {
    private let logger = AppLogger.logger(for: .networking)

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // Implementation
    }
}
```

See `docs/patterns/networking.md` for implementation guide.
```

**Step 3: Create Core/Persistence placeholder**

```bash
mkdir -p MyApp/Core/Persistence
```

Create `MyApp/Core/Persistence/README.md`:
```markdown
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
```

**Step 4: Commit**

```bash
git add MyApp/Core/
git commit -m "feat: create Core directory structure with placeholders"
```

---

### Task 3: Create LogCategory Enum

**Files:**
- Create: `MyApp/Core/Logging/LogCategory.swift`

**Step 1: Create LogCategory file**

Create `MyApp/Core/Logging/LogCategory.swift`:
```swift
import Foundation

/// Categorizes log messages for filtering and organization.
///
/// Use these categories to organize logs by functional area:
/// - `.startup`: App lifecycle and initialization
/// - `.networking`: API calls, network requests
/// - `.ui`: User interface events and interactions
/// - `.data`: Data persistence and processing
/// - `.auth`: Authentication and authorization
/// - `.general`: Uncategorized logs
enum LogCategory: String, Sendable {
    case startup
    case networking
    case ui
    case data
    case auth
    case general
}
```

**Step 2: Commit**

```bash
git add MyApp/Core/Logging/LogCategory.swift
git commit -m "feat: add LogCategory enum for structured logging"
```

---

### Task 4: Create AppLogger Factory

**Files:**
- Create: `MyApp/Core/Logging/AppLogger.swift`

**Step 1: Create AppLogger file**

Create `MyApp/Core/Logging/AppLogger.swift`:
```swift
import os.log

/// Centralized logging system for the app.
///
/// Provides type-safe logger creation with consistent subsystem naming.
/// All loggers use the app's bundle identifier as the subsystem.
///
/// Usage:
/// ```swift
/// private let logger = AppLogger.logger(for: .networking)
/// logger.info("Request completed successfully")
/// ```
enum AppLogger {
    /// Centralized subsystem identifier.
    ///
    /// Update this when customizing the template for a new project.
    static let subsystem = "com.example.MyApp"

    /// Creates a logger for the specified category.
    ///
    /// - Parameter category: The functional category for this logger
    /// - Returns: Configured Logger instance
    static func logger(for category: LogCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }
}
```

**Step 2: Commit**

```bash
git add MyApp/Core/Logging/AppLogger.swift
git commit -m "feat: add AppLogger factory for centralized logging"
```

---

### Task 5: Update MyAppApp to Use AppLogger

**Files:**
- Modify: `MyApp/MyAppApp.swift`

**Step 1: Replace existing logger with AppLogger**

Update `MyApp/MyAppApp.swift`:
```swift
import SwiftUI
import os.log

@main
struct MyAppApp: App {
    private let logger = AppLogger.logger(for: .startup)

    init() {
        logger.log("🚀 MyApp starting up on iOS 26!")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**Step 2: Build to verify**

```bash
xcodebuild -project MyApp.xcodeproj -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: Build succeeds

**Step 3: Commit**

```bash
git add MyApp/MyAppApp.swift
git commit -m "refactor: use AppLogger in app entry point"
```

---

### Task 6: Create Features Directory Structure

**Files:**
- Create: `MyApp/Features/Welcome/.gitkeep`
- Create: `MyApp/Features/Welcome/Components/.gitkeep`

**Step 1: Create Features/Welcome directories**

```bash
mkdir -p MyApp/Features/Welcome/Components
touch MyApp/Features/Welcome/.gitkeep
touch MyApp/Features/Welcome/Components/.gitkeep
```

**Step 2: Commit**

```bash
git add MyApp/Features/
git commit -m "feat: create Features directory structure"
```

---

### Task 7: Move ContentView to Welcome Feature

**Files:**
- Create: `MyApp/Features/Welcome/WelcomeView.swift`
- Modify: `MyApp/ContentView.swift` (will be deleted)
- Modify: `MyApp/MyAppApp.swift`

**Step 1: Create WelcomeView in Features**

Create `MyApp/Features/Welcome/WelcomeView.swift`:
```swift
import SwiftUI

/// Main welcome screen shown on app launch.
struct WelcomeView: View {
    var body: some View {
        ZStack {
            GradientBackground()
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, iOS 26!")
                    .font(.title)
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeView()
        .preferredColorScheme(.dark)
}
```

**Step 2: Update MyAppApp to use WelcomeView**

Update `MyApp/MyAppApp.swift`:
```swift
import SwiftUI
import os.log

@main
struct MyAppApp: App {
    private let logger = AppLogger.logger(for: .startup)

    init() {
        logger.log("🚀 MyApp starting up on iOS 26!")
    }

    var body: some Scene {
        WindowGroup {
            WelcomeView()
        }
    }
}
```

**Step 3: Delete old ContentView**

```bash
git rm MyApp/ContentView.swift
```

**Step 4: Build to verify**

```bash
xcodebuild -project MyApp.xcodeproj -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: Build succeeds

**Step 5: Commit**

```bash
git add MyApp/Features/Welcome/WelcomeView.swift MyApp/MyAppApp.swift
git commit -m "refactor: move ContentView to Features/Welcome/WelcomeView"
```

---

### Task 8: Create Shared Directory Structure

**Files:**
- Create: `MyApp/Shared/Components/.gitkeep`
- Create: `MyApp/Shared/Extensions/.gitkeep`
- Create: `MyApp/Shared/DesignSystem/.gitkeep`
- Create: `MyApp/Shared/Utilities/.gitkeep`

**Step 1: Create Shared directories**

```bash
mkdir -p MyApp/Shared/Components
mkdir -p MyApp/Shared/Extensions
mkdir -p MyApp/Shared/DesignSystem
mkdir -p MyApp/Shared/Utilities
touch MyApp/Shared/Components/.gitkeep
touch MyApp/Shared/Extensions/.gitkeep
touch MyApp/Shared/DesignSystem/.gitkeep
touch MyApp/Shared/Utilities/.gitkeep
```

**Step 2: Commit**

```bash
git add MyApp/Shared/
git commit -m "feat: create Shared directory structure"
```

---

### Task 9: Move GradientBackground to Shared/Components

**Files:**
- Create: `MyApp/Shared/Components/GradientBackground.swift`
- Modify: `MyApp/Views/Components/GradientBackground.swift` (will be deleted)

**Step 1: Create GradientBackground in Shared**

Create `MyApp/Shared/Components/GradientBackground.swift`:
```swift
import SwiftUI

/// Reusable gradient background component.
///
/// Provides a consistent gradient effect across the app.
/// Uses colors from the app's design system.
struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackground()
}
```

**Step 2: Delete old GradientBackground**

```bash
git rm -r MyApp/Views/
```

**Step 3: Build to verify**

```bash
xcodebuild -project MyApp.xcodeproj -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: Build succeeds

**Step 4: Commit**

```bash
git add MyApp/Shared/Components/GradientBackground.swift
git commit -m "refactor: move GradientBackground to Shared/Components"
```

---

### Task 10: Move DesignConstants to Shared/DesignSystem

**Files:**
- Create: `MyApp/Shared/DesignSystem/DesignConstants.swift`
- Modify: `MyApp/Models/DesignConstants.swift` (will be deleted)

**Step 1: Create DesignConstants in Shared**

Create `MyApp/Shared/DesignSystem/DesignConstants.swift`:
```swift
import Foundation

/// Global design constants for the app.
///
/// Centralizes spacing, sizing, and other design tokens
/// to ensure consistency across the UI.
enum DesignConstants {
    /// Standard spacing values
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    /// Corner radius values
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
    }

    /// Animation durations
    enum Animation {
        static let quick: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
    }
}
```

**Step 2: Delete old Models directory**

```bash
git rm -r MyApp/Models/
```

**Step 3: Build to verify**

```bash
xcodebuild -project MyApp.xcodeproj -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: Build succeeds

**Step 4: Commit**

```bash
git add MyApp/Shared/DesignSystem/DesignConstants.swift
git commit -m "refactor: move DesignConstants to Shared/DesignSystem"
```

---

## Phase 2: Testing Framework

### Task 11: Add Swift Testing Test Target

**Files:**
- Modify: `MyApp.xcodeproj/project.pbxproj`

**Step 1: Create test target via Xcode project modification**

Note: This requires manual Xcode project modification. Create a placeholder test file first.

Create `MyAppTests/AppLoggerTests.swift`:
```swift
import Testing
@testable import MyApp

@Suite("AppLogger Tests")
struct AppLoggerTests {

    @Test("Creates logger with correct subsystem")
    func testLoggerCreation() {
        let logger = AppLogger.logger(for: .networking)
        // Logger created successfully
        #expect(AppLogger.subsystem == "com.example.MyApp")
    }

    @Test("Creates loggers for all categories", arguments: [
        LogCategory.startup,
        LogCategory.networking,
        LogCategory.ui,
        LogCategory.data,
        LogCategory.auth,
        LogCategory.general
    ])
    func testAllCategories(category: LogCategory) {
        let logger = AppLogger.logger(for: category)
        // Logger created for each category
        #expect(AppLogger.subsystem == "com.example.MyApp")
    }
}
```

**Step 2: Add test target to Xcode project**

```bash
# This step requires Xcode CLI tools or manual project editing
# For now, document the manual step
echo "Manual step: Add Swift Testing test target named 'MyAppTests' in Xcode"
```

**Step 3: Commit test file**

```bash
git add MyAppTests/AppLoggerTests.swift
git commit -m "test: add AppLogger tests with Swift Testing"
```

---

### Task 12: Add WelcomeView Tests

**Files:**
- Create: `MyAppTests/Features/Welcome/WelcomeViewTests.swift`

**Step 1: Create test directory structure**

```bash
mkdir -p MyAppTests/Features/Welcome
```

**Step 2: Create WelcomeView tests**

Create `MyAppTests/Features/Welcome/WelcomeViewTests.swift`:
```swift
import Testing
import SwiftUI
@testable import MyApp

@Suite("WelcomeView Tests")
struct WelcomeViewTests {

    @Test("WelcomeView initializes correctly")
    func testViewInitialization() {
        let view = WelcomeView()
        // View should initialize without errors
        #expect(view != nil)
    }

    @Test("WelcomeView has correct structure")
    func testViewStructure() {
        let view = WelcomeView()
        // Verify view can be rendered
        let body = view.body
        #expect(body != nil)
    }
}
```

**Step 3: Commit**

```bash
git add MyAppTests/Features/Welcome/WelcomeViewTests.swift
git commit -m "test: add WelcomeView tests"
```

---

### Task 13: Add Test Helpers

**Files:**
- Create: `MyAppTests/TestHelpers/ViewTestHelpers.swift`

**Step 1: Create TestHelpers directory**

```bash
mkdir -p MyAppTests/TestHelpers
```

**Step 2: Create view test helpers**

Create `MyAppTests/TestHelpers/ViewTestHelpers.swift`:
```swift
import SwiftUI
import Testing

/// Helper utilities for testing SwiftUI views.
enum ViewTestHelpers {

    /// Creates a test host for SwiftUI views.
    ///
    /// Useful for testing views that need a window or environment.
    static func createTestHost<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(width: 375, height: 812) // iPhone size
    }
}
```

**Step 3: Commit**

```bash
git add MyAppTests/TestHelpers/ViewTestHelpers.swift
git commit -m "test: add ViewTestHelpers for SwiftUI testing"
```

---

## Phase 3: Documentation

### Task 14: Create Documentation Directory Structure

**Files:**
- Create: `docs/README.md`
- Create: `docs/guides/.gitkeep`
- Create: `docs/patterns/.gitkeep`

**Step 1: Create docs structure**

```bash
mkdir -p docs/guides
mkdir -p docs/patterns
touch docs/guides/.gitkeep
touch docs/patterns/.gitkeep
```

**Step 2: Create docs index**

Create `docs/README.md`:
```markdown
# MyApp Documentation

Complete documentation for the iOS template project.

## Quick Links

- [Architecture Guide](guides/architecture.md) - Feature-based organization
- [Logging Guide](guides/logging.md) - Using AppLogger
- [Testing Guide](guides/testing.md) - Swift Testing patterns
- [Swift 6 Concurrency](guides/swift6-concurrency.md) - Actor patterns
- [Customizing Template](guides/customizing-template.md) - Setup for new projects

## Guides

Comprehensive how-to guides for common tasks:

- [Adding Features](guides/adding-features.md) - Step-by-step feature creation
- [Architecture](guides/architecture.md) - Project organization principles
- [Logging](guides/logging.md) - Structured logging with AppLogger
- [Testing](guides/testing.md) - Unit and UI testing patterns
- [Swift 6 Concurrency](guides/swift6-concurrency.md) - Modern concurrency patterns
- [Customizing Template](guides/customizing-template.md) - Adapting for new projects

## Patterns

Implementation patterns and best practices:

- [View Models](patterns/view-models.md) - @Observable patterns
- [Navigation](patterns/navigation.md) - SwiftUI navigation
- [Error Handling](patterns/error-handling.md) - Result types and logging

## Plans

Design documents and implementation plans:

- [Template Design](plans/2026-01-04-ios-template-design.md) - Overall architecture
- [Implementation Plan](plans/2026-01-04-ios-template-implementation.md) - Build steps

## CLI Reference

See main [README.md](../README.md) for comprehensive CLI command reference.
```

**Step 3: Commit**

```bash
git add docs/
git commit -m "docs: create documentation structure and index"
```

---

### Task 15: Write Logging Guide

**Files:**
- Create: `docs/guides/logging.md`

**Step 1: Create logging guide**

Create `docs/guides/logging.md`:
```markdown
# Logging Guide

Comprehensive guide to using AppLogger for structured logging.

## Overview

This template uses `AppLogger`, a lightweight wrapper around `os.log` that provides:

- **Type-safe categories** - Organize logs by functional area
- **Centralized subsystem** - Single source of truth for app identifier
- **Privacy by default** - Respects Apple's privacy guidelines
- **Swift 6 compatible** - Works seamlessly with actors and async code

## Basic Usage

### Creating a Logger

```swift
import os.log

private let logger = AppLogger.logger(for: .networking)
```

### Logging Messages

```swift
// Debug - detailed information for debugging
logger.debug("Request started: \(url)")

// Info - general informational messages
logger.info("User logged in successfully")

// Notice - significant events
logger.notice("Cache cleared")

// Error - error conditions
logger.error("Failed to fetch data: \(error.localizedDescription)")

// Fault - critical failures
logger.fault("Database corrupted")
```

## Categories

Choose the appropriate category for your logger:

| Category | Use Case | Example |
|----------|----------|---------|
| `.startup` | App lifecycle, initialization | "App launched", "Configuration loaded" |
| `.networking` | API calls, network requests | "Request started", "Response received" |
| `.ui` | User interactions, view events | "Button tapped", "Screen appeared" |
| `.data` | Data persistence, processing | "Item saved", "Cache updated" |
| `.auth` | Authentication, authorization | "Login attempt", "Token refreshed" |
| `.general` | Uncategorized logs | Miscellaneous events |

## Privacy

Protect user data by marking sensitive information as private:

```swift
// Public - safe to log (default for string literals)
logger.info("User logged in")

// Private - redacted in logs
logger.info("User ID: \(userID, privacy: .private)")

// Public override - explicitly public
logger.info("Public ID: \(publicID, privacy: .public)")
```

**Default behavior:**
- String literals are public
- String interpolations are private by default
- Explicitly mark all user data as `.private`

## Log Levels

Use appropriate log levels:

1. **Debug** - Detailed diagnostic information
   - Only visible in debug builds
   - Use liberally during development
   - Remove or disable in production

2. **Info** - General informational messages
   - Important events worth recording
   - Visible in production
   - Keep concise

3. **Notice** - Significant but normal events
   - Notable state changes
   - Successful completion of important operations

4. **Error** - Error conditions
   - Recoverable errors
   - Failed operations
   - Include error details

5. **Fault** - Critical failures
   - Unrecoverable errors
   - Data corruption
   - System-level failures

## Examples by Scenario

### App Startup

```swift
private let logger = AppLogger.logger(for: .startup)

func application(_ application: UIApplication, didFinishLaunchingWithOptions...) {
    logger.info("App starting up")
    logger.debug("Launch options: \(launchOptions)")
}
```

### Networking

```swift
private let logger = AppLogger.logger(for: .networking)

func fetchData() async throws -> Data {
    logger.debug("Starting request to \(url)")

    do {
        let data = try await URLSession.shared.data(from: url)
        logger.info("Request completed: \(data.count) bytes")
        return data
    } catch {
        logger.error("Request failed: \(error.localizedDescription)")
        throw error
    }
}
```

### User Actions

```swift
private let logger = AppLogger.logger(for: .ui)

func handleButtonTap() {
    logger.debug("Button tapped")
    // Handle action
    logger.info("Action completed successfully")
}
```

### Data Operations

```swift
private let logger = AppLogger.logger(for: .data)

actor DataCache {
    private let logger = AppLogger.logger(for: .data)

    func save(_ item: Item) async throws {
        logger.debug("Saving item: \(item.id, privacy: .private)")
        // Save operation
        logger.info("Item saved successfully")
    }
}
```

### Error Handling

```swift
private let logger = AppLogger.logger(for: .general)

func processData() {
    do {
        try performOperation()
    } catch let error as ValidationError {
        logger.error("Validation failed: \(error.message)")
    } catch {
        logger.fault("Unexpected error: \(error)")
    }
}
```

## Viewing Logs

### During Development

**Xcode Console:**
- Logs appear automatically when running from Xcode
- Filter by subsystem: `com.example.MyApp`

**Command Line:**
```bash
# Stream logs while app runs
/usr/bin/log stream --level debug --predicate "subsystem == 'com.example.MyApp'"

# Filter by category
/usr/bin/log stream --predicate "subsystem == 'com.example.MyApp' AND category == 'networking'"
```

### Production

Use Console.app to view logs from devices:
1. Open Console.app on Mac
2. Connect device
3. Filter by subsystem: `com.example.MyApp`
4. Export logs for analysis

## Best Practices

### Do

- ✅ Use appropriate log levels
- ✅ Mark sensitive data as private
- ✅ Keep messages concise and actionable
- ✅ Include context (operation, state)
- ✅ Log errors with details
- ✅ Use categories consistently

### Don't

- ❌ Log passwords, tokens, or PII
- ❌ Log in tight loops
- ❌ Leave debug logs in production code paths
- ❌ Use generic messages ("Error occurred")
- ❌ Log sensitive user data
- ❌ Mix categories (networking logs in .ui)

## Customizing for New Projects

When customizing the template:

1. Update `AppLogger.subsystem` in `Core/Logging/AppLogger.swift`
2. Change from `"com.example.MyApp"` to your bundle ID
3. Add new categories to `LogCategory` enum if needed

```swift
enum AppLogger {
    static let subsystem = "com.yourcompany.YourApp"  // Update this
    // ...
}
```

## Performance Considerations

`os.log` is highly optimized:

- **Zero cost when disabled** - Debug logs have no overhead in release builds
- **Async by default** - Doesn't block your code
- **Compressed storage** - Efficient on-device storage
- **Lazy string interpolation** - Only evaluated when logs are enabled

Safe to use liberally without performance concerns.

## Further Reading

- [Apple Logging Documentation](https://developer.apple.com/documentation/os/logging)
- [Swift 6 Concurrency](swift6-concurrency.md)
- [Testing Guide](testing.md)
```

**Step 2: Commit**

```bash
git add docs/guides/logging.md
git commit -m "docs: add comprehensive logging guide"
```

---

### Task 16: Write Architecture Guide

**Files:**
- Create: `docs/guides/architecture.md`

**Step 1: Create architecture guide**

Create `docs/guides/architecture.md`:
```markdown
# Architecture Guide

Comprehensive guide to the template's feature-based architecture.

## Overview

This template uses a **feature-based architecture** that scales from small apps to large projects. Code is organized by feature rather than technical layer.

## Principles

1. **Features are self-contained** - Everything for a feature lives together
2. **Core provides infrastructure** - Shared services used across features
3. **Shared contains utilities** - Reusable components and helpers
4. **Dependencies flow inward** - Features depend on Core/Shared, not each other

## Directory Structure

```
MyApp/
├── Core/              # Infrastructure (logging, networking, persistence)
├── Features/          # Feature modules (Welcome, Profile, Settings, etc.)
├── Shared/            # Utilities (components, extensions, design system)
└── MyAppApp.swift     # App entry point
```

## Core/

Infrastructure used across multiple features:

```
Core/
├── Logging/           # AppLogger system
├── Networking/        # API client (future)
└── Persistence/       # SwiftData models (future)
```

**When to add to Core:**
- Used by 3+ features
- Fundamental infrastructure (logging, networking)
- No UI components

**When not to add to Core:**
- Feature-specific logic
- UI components
- Single-feature utilities

## Features/

Self-contained feature modules:

```
Features/
└── Welcome/
    ├── WelcomeView.swift         # Main view
    ├── WelcomeViewModel.swift    # View model (@Observable)
    ├── Components/               # Feature-specific components
    │   └── WelcomeCard.swift
    └── README.md                 # Feature documentation
```

**Feature anatomy:**
- **Views** - SwiftUI views for this feature
- **View Models** - @Observable classes with business logic
- **Components** - UI components used only in this feature
- **README.md** - Purpose, usage, dependencies

**When to create a new feature:**
- Distinct user-facing functionality
- Can be developed/tested independently
- Has clear boundaries

**When to extend existing feature:**
- Closely related functionality
- Shares view models/state
- Would create tight coupling as separate feature

## Shared/

Cross-feature utilities and components:

```
Shared/
├── Components/        # Reusable UI (buttons, cards, backgrounds)
├── Extensions/        # Swift/SwiftUI extensions
├── DesignSystem/      # Design tokens (colors, spacing, typography)
└── Utilities/         # Helper functions, formatters
```

**When to add to Shared:**
- Used by 2+ features
- Reusable UI components
- Extensions that benefit multiple features
- Design system elements

**When not to add to Shared:**
- Feature-specific components
- Core infrastructure
- Single-use utilities

## Dependency Rules

**Valid dependencies:**
```
Features → Core ✅
Features → Shared ✅
Shared → Core ✅

Features → Features ❌
Core → Features ❌
Core → Shared ❌
```

**Why these rules:**
- Prevents circular dependencies
- Makes features independently testable
- Enables modularization later

## Example: Adding a Profile Feature

### Step 1: Create feature directory

```bash
mkdir -p MyApp/Features/Profile/Components
```

### Step 2: Create view model

`Features/Profile/ProfileViewModel.swift`:
```swift
import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    private let logger = AppLogger.logger(for: .ui)

    var userName: String = ""
    var isLoading: Bool = false

    func load() async {
        logger.debug("Loading profile")
        isLoading = true
        // Load data
        isLoading = false
        logger.info("Profile loaded")
    }
}
```

### Step 3: Create view

`Features/Profile/ProfileView.swift`:
```swift
import SwiftUI

struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.userName)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
```

### Step 4: Document feature

`Features/Profile/README.md`:
```markdown
# Profile Feature

User profile management.

## Components
- ProfileView - Main profile screen
- ProfileViewModel - Profile state and logic

## Dependencies
- Core/Logging - Logging infrastructure
```

## Testing Structure

Tests mirror production structure:

```
MyAppTests/
├── Core/
│   └── Logging/
│       └── AppLoggerTests.swift
├── Features/
│   └── Welcome/
│       └── WelcomeViewTests.swift
└── TestHelpers/
    └── ViewTestHelpers.swift
```

**Benefits:**
- Easy to find tests for any component
- Natural organization as project grows
- Encourages testing all layers

## Swift 6 Concurrency

All architecture patterns work with Swift 6:

- **View Models** - `@Observable @MainActor`
- **Services** - `actor` for shared state
- **Models** - `Sendable` by default

See [Swift 6 Concurrency Guide](swift6-concurrency.md) for details.

## Scaling

### Small Projects (1-3 features)
- Keep structure simple
- Don't over-organize
- Use Shared/ liberally

### Medium Projects (4-10 features)
- Enforce dependency rules
- Add feature READMEs
- Consider feature grouping

### Large Projects (10+ features)
- Group related features
- Extract to Swift packages
- Implement dependency injection

## Migration Strategy

From other architectures:

**MVC → Feature-based:**
1. Create Features/ directory
2. Move related view controllers to feature
3. Convert to SwiftUI incrementally

**MVVM → Feature-based:**
1. Create Features/ directory
2. Move view models to features
3. Convert to @Observable

**Layer-based → Feature-based:**
1. Identify features
2. Move files to feature directories
3. Update imports

## Best Practices

### Do
- ✅ Keep features independent
- ✅ Document feature boundaries
- ✅ Use Core for infrastructure
- ✅ Follow dependency rules
- ✅ Test features in isolation

### Don't
- ❌ Create features for single views
- ❌ Share state between features
- ❌ Add UI to Core
- ❌ Import features from each other
- ❌ Over-organize early

## Further Reading

- [Adding Features Guide](adding-features.md)
- [View Models Pattern](../patterns/view-models.md)
- [Testing Guide](testing.md)
```

**Step 2: Commit**

```bash
git add docs/guides/architecture.md
git commit -m "docs: add architecture guide"
```

---

### Task 17: Write Testing Guide

**Files:**
- Create: `docs/guides/testing.md`

**Step 1: Create testing guide**

Create `docs/guides/testing.md`:
```markdown
# Testing Guide

Comprehensive guide to testing with Swift Testing framework.

## Overview

This template uses **Swift Testing**, Apple's modern testing framework introduced in Xcode 16. It provides:

- **@Test macro** - Clear test declarations
- **Async/await support** - Native async testing
- **Parameterized tests** - Test multiple inputs easily
- **Better error messages** - More helpful failures
- **Swift 6 compatible** - Works with actors and concurrency

## Basic Testing

### Test Structure

```swift
import Testing
@testable import MyApp

@Suite("Feature Name Tests")
struct FeatureTests {

    @Test("Describes what this tests")
    func testSomething() {
        let result = function()
        #expect(result == expected)
    }
}
```

### Expectations

```swift
// Basic expectation
#expect(value == expected)

// Optional unwrapping
let unwrapped = try #require(optional)

// Throwing
#expect(throws: ErrorType.self) {
    try throwingFunction()
}

// Bool conditions
#expect(condition)
#expect(!condition)
```

## Async Testing

Test async functions naturally:

```swift
@Test("Async operation completes")
func testAsyncOperation() async throws {
    let result = await asyncFunction()
    #expect(result != nil)
}

@Test("Async throws correct error")
func testAsyncError() async {
    await #expect(throws: NetworkError.self) {
        try await failingFunction()
    }
}
```

## Parameterized Tests

Test multiple inputs with one test:

```swift
@Test("Validates multiple inputs", arguments: [
    ("valid@email.com", true),
    ("invalid", false),
    ("@missing.com", false)
])
func testEmailValidation(email: String, expected: Bool) {
    let result = isValidEmail(email)
    #expect(result == expected)
}

// Test all enum cases
@Test("Works for all categories", arguments: [
    LogCategory.startup,
    .networking,
    .ui,
    .data,
    .auth,
    .general
])
func testAllCategories(category: LogCategory) {
    let logger = AppLogger.logger(for: category)
    #expect(logger != nil)
}
```

## Testing SwiftUI Views

Test views directly without launching the app:

```swift
import Testing
import SwiftUI
@testable import MyApp

@Suite("WelcomeView Tests")
struct WelcomeViewTests {

    @Test("View initializes correctly")
    func testInitialization() {
        let view = WelcomeView()
        #expect(view != nil)
    }

    @Test("View model updates view")
    func testViewModelBinding() {
        let viewModel = WelcomeViewModel()
        let view = WelcomeView(viewModel: viewModel)

        viewModel.message = "Test"
        #expect(viewModel.message == "Test")
    }
}
```

## Testing Actors

Test actor-isolated code:

```swift
@Test("Actor maintains isolation")
func testActorIsolation() async {
    actor Counter {
        var count = 0
        func increment() { count += 1 }
        func get() -> Int { count }
    }

    let counter = Counter()
    await counter.increment()
    let value = await counter.get()
    #expect(value == 1)
}
```

## Testing MainActor Code

Test UI code on MainActor:

```swift
@Test("View model on MainActor")
@MainActor
func testMainActorViewModel() async {
    let viewModel = WelcomeViewModel()
    await viewModel.load()
    #expect(viewModel.isLoaded)
}
```

## Test Organization

Mirror production structure:

```
MyAppTests/
├── Core/
│   └── Logging/
│       └── AppLoggerTests.swift
├── Features/
│   └── Welcome/
│       ├── WelcomeViewTests.swift
│       └── WelcomeViewModelTests.swift
└── TestHelpers/
    └── ViewTestHelpers.swift
```

## Test Helpers

Create reusable test utilities:

```swift
// TestHelpers/ViewTestHelpers.swift
import SwiftUI

enum ViewTestHelpers {
    static func createTestHost<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .frame(width: 375, height: 812)
    }
}
```

## Running Tests

### From Command Line

```bash
# Run all tests
swift test

# Run specific test
swift test --filter FeatureTests

# Run with verbose output
swift test -v

# Using xcodebuild
xcodebuild test \
  -scheme MyApp \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

### From Xcode

1. Open project in Xcode
2. Press Cmd+U to run all tests
3. Click diamond icon next to test to run individual test

## Example: Testing a Feature

### 1. Test View Model Logic

```swift
@Suite("ProfileViewModel Tests")
struct ProfileViewModelTests {

    @Test("Loads profile data")
    @MainActor
    func testLoadProfile() async {
        let viewModel = ProfileViewModel()

        #expect(viewModel.isLoading == false)

        await viewModel.load()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.userName != "")
    }

    @Test("Handles load error")
    @MainActor
    func testLoadError() async {
        let viewModel = ProfileViewModel(shouldFail: true)

        await viewModel.load()

        #expect(viewModel.error != nil)
    }
}
```

### 2. Test View

```swift
@Suite("ProfileView Tests")
struct ProfileViewTests {

    @Test("Shows loading state")
    func testLoadingState() {
        let viewModel = ProfileViewModel()
        viewModel.isLoading = true

        let view = ProfileView(viewModel: viewModel)
        #expect(view != nil)
    }

    @Test("Shows profile data")
    func testProfileData() {
        let viewModel = ProfileViewModel()
        viewModel.userName = "Test User"

        let view = ProfileView(viewModel: viewModel)
        #expect(viewModel.userName == "Test User")
    }
}
```

### 3. Test Integration

```swift
@Suite("Profile Integration Tests")
struct ProfileIntegrationTests {

    @Test("Full profile load flow")
    @MainActor
    func testFullFlow() async {
        let viewModel = ProfileViewModel()
        let view = ProfileView(viewModel: viewModel)

        // Initial state
        #expect(viewModel.isLoading == false)

        // Trigger load
        await viewModel.load()

        // Final state
        #expect(viewModel.isLoading == false)
        #expect(viewModel.userName != "")
        #expect(viewModel.error == nil)
    }
}
```

## Best Practices

### Do
- ✅ Test business logic thoroughly
- ✅ Use parameterized tests for multiple inputs
- ✅ Test async code with async/await
- ✅ Keep tests focused and independent
- ✅ Use descriptive test names
- ✅ Mirror production structure

### Don't
- ❌ Test SwiftUI framework behavior
- ❌ Test third-party libraries
- ❌ Create interdependent tests
- ❌ Test implementation details
- ❌ Ignore flaky tests
- ❌ Skip edge cases

## Common Patterns

### Testing Optional Results

```swift
@Test("Returns valid result")
func testValidResult() throws {
    let result = function()
    let unwrapped = try #require(result)
    #expect(unwrapped.isValid)
}
```

### Testing Error Cases

```swift
@Test("Throws on invalid input")
func testErrorCase() {
    #expect(throws: ValidationError.self) {
        try validate("")
    }
}
```

### Testing Collections

```swift
@Test("Returns correct count")
func testCount() {
    let items = fetchItems()
    #expect(items.count == 5)
}

@Test("Contains expected item")
func testContains() {
    let items = fetchItems()
    #expect(items.contains { $0.id == "123" })
}
```

## Migration from XCTest

If migrating from XCTest:

```swift
// XCTest
func testExample() {
    XCTAssertEqual(result, expected)
}

// Swift Testing
@Test func example() {
    #expect(result == expected)
}
```

```swift
// XCTest
func testAsync() async throws {
    let result = await fetch()
    XCTAssertNotNil(result)
}

// Swift Testing
@Test func async() async throws {
    let result = await fetch()
    #expect(result != nil)
}
```

## Further Reading

- [Swift Testing Documentation](https://developer.apple.com/documentation/testing)
- [Architecture Guide](architecture.md)
- [Swift 6 Concurrency](swift6-concurrency.md)
```

**Step 2: Commit**

```bash
git add docs/guides/testing.md
git commit -m "docs: add comprehensive testing guide"
```

---

## Phase 4: Build & Tooling

### Task 18: Create Scripts Directory

**Files:**
- Create: `scripts/build.sh`
- Create: `scripts/test.sh`
- Create: `scripts/install.sh`
- Create: `scripts/bootstrap.sh`

**Step 1: Create scripts directory**

```bash
mkdir -p scripts
```

**Step 2: Create build script**

Create `scripts/build.sh`:
```bash
#!/bin/bash
set -e

# Build MyApp for iOS Simulator
# Usage: ./scripts/build.sh [simulator-udid]

PROJECT="MyApp.xcodeproj"
SCHEME="MyApp"
CONFIGURATION="Debug"
DERIVED_DATA="./build"

# Use provided UDID or find iPhone 17
if [ -n "$1" ]; then
    UDID="$1"
else
    UDID=$(xcrun simctl list devices iPhone available --json | jq -r '.devices | to_entries[] | select(.key | contains("iOS")) | .value[] | select(.name == "iPhone 17") | .udid' | head -1)
fi

if [ -z "$UDID" ]; then
    echo "Error: No simulator found. Provide UDID as argument."
    exit 1
fi

echo "Building for simulator: $UDID"

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$UDID" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA" \
  build

echo "✅ Build complete!"
```

**Step 3: Create test script**

Create `scripts/test.sh`:
```bash
#!/bin/bash
set -e

# Run all tests for MyApp
# Usage: ./scripts/test.sh [simulator-udid]

PROJECT="MyApp.xcodeproj"
SCHEME="MyApp"
DERIVED_DATA="./build"

# Use provided UDID or find iPhone 17
if [ -n "$1" ]; then
    UDID="$1"
else
    UDID=$(xcrun simctl list devices iPhone available --json | jq -r '.devices | to_entries[] | select(.key | contains("iOS")) | .value[] | select(.name == "iPhone 17") | .udid' | head -1)
fi

if [ -z "$UDID" ]; then
    echo "Error: No simulator found. Provide UDID as argument."
    exit 1
fi

echo "Running tests on simulator: $UDID"

# Boot simulator if needed
xcrun simctl boot "$UDID" 2>/dev/null || true

xcodebuild test \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath "$DERIVED_DATA"

echo "✅ Tests complete!"
```

**Step 4: Create install script**

Create `scripts/install.sh`:
```bash
#!/bin/bash
set -e

# Build, install, and launch MyApp
# Usage: ./scripts/install.sh [simulator-udid]

BUNDLE_ID="com.example.MyApp"
APP_PATH="./build/Build/Products/Debug-iphonesimulator/MyApp.app"

# Use provided UDID or find iPhone 17
if [ -n "$1" ]; then
    UDID="$1"
else
    UDID=$(xcrun simctl list devices iPhone available --json | jq -r '.devices | to_entries[] | select(.key | contains("iOS")) | .value[] | select(.name == "iPhone 17") | .udid' | head -1)
fi

if [ -z "$UDID" ]; then
    echo "Error: No simulator found. Provide UDID as argument."
    exit 1
fi

# Build
echo "Building..."
./scripts/build.sh "$UDID"

# Boot simulator
echo "Booting simulator..."
xcrun simctl boot "$UDID" 2>/dev/null || true

# Install
echo "Installing app..."
xcrun simctl install "$UDID" "$APP_PATH"

# Launch
echo "Launching app..."
xcrun simctl launch "$UDID" "$BUNDLE_ID"

echo "✅ App installed and launched!"
echo "View logs: /usr/bin/log stream --predicate \"subsystem == '$BUNDLE_ID'\""
```

**Step 5: Create bootstrap script**

Create `scripts/bootstrap.sh`:
```bash
#!/bin/bash
set -e

# Bootstrap development environment
# Usage: ./scripts/bootstrap.sh

echo "Bootstrapping MyApp development environment..."

# Check Xcode version
XCODE_VERSION=$(xcodebuild -version | head -1 | awk '{print $2}')
echo "Xcode version: $XCODE_VERSION"

# Check for iOS 26 simulator
SIMULATORS=$(xcrun simctl list devices iPhone available --json | jq -r '.devices | to_entries[] | select(.key | contains("iOS-26")) | .value[] | .name')

if [ -z "$SIMULATORS" ]; then
    echo "⚠️  No iOS 26 simulators found. Install from Xcode > Settings > Platforms"
else
    echo "Available iOS 26 simulators:"
    echo "$SIMULATORS"
fi

# Create build directory
mkdir -p build

echo "✅ Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  1. Run tests: ./scripts/test.sh"
echo "  2. Build app: ./scripts/build.sh"
echo "  3. Install app: ./scripts/install.sh"
```

**Step 6: Make scripts executable**

```bash
chmod +x scripts/*.sh
```

**Step 7: Commit**

```bash
git add scripts/
git commit -m "feat: add CLI build, test, install, and bootstrap scripts"
```

---

## Phase 5: Template Automation

### Task 19: Create Setup Script

**Files:**
- Create: `setup.sh`

**Step 1: Create setup script**

Create `setup.sh`:
```bash
#!/bin/bash
set -e

# Template customization script
# Usage: ./setup.sh --name AppName --bundle-id com.company.app --team-id ABC123

show_usage() {
    echo "Usage: ./setup.sh --name <AppName> --bundle-id <com.company.app> --team-id <TEAM_ID>"
    echo ""
    echo "Options:"
    echo "  --name        New app name (e.g., 'CoolApp')"
    echo "  --bundle-id   New bundle identifier (e.g., 'com.company.coolapp')"
    echo "  --team-id     Apple Developer Team ID (e.g., 'ABC123XYZ')"
    echo "  --fresh-git   Initialize fresh git repo (removes template history)"
    echo ""
    echo "Example:"
    echo "  ./setup.sh --name CoolApp --bundle-id com.company.coolapp --team-id ABC123XYZ"
    exit 1
}

# Parse arguments
FRESH_GIT=false
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            NEW_NAME="$2"
            shift 2
            ;;
        --bundle-id)
            NEW_BUNDLE_ID="$2"
            shift 2
            ;;
        --team-id)
            NEW_TEAM_ID="$2"
            shift 2
            ;;
        --fresh-git)
            FRESH_GIT=true
            shift
            ;;
        *)
            show_usage
            ;;
    esac
done

# Validate required arguments
if [ -z "$NEW_NAME" ] || [ -z "$NEW_BUNDLE_ID" ] || [ -z "$NEW_TEAM_ID" ]; then
    show_usage
fi

echo "Customizing template..."
echo "  New name: $NEW_NAME"
echo "  Bundle ID: $NEW_BUNDLE_ID"
echo "  Team ID: $NEW_TEAM_ID"
echo ""

OLD_NAME="MyApp"
OLD_BUNDLE_ID="com.example.MyApp"
OLD_TEAM_ID="9C77FVAH99"

# 1. Rename Xcode project
echo "📦 Renaming Xcode project..."
mv "${OLD_NAME}.xcodeproj" "${NEW_NAME}.xcodeproj"

# 2. Update project.pbxproj
echo "⚙️  Updating project configuration..."
sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" "${NEW_NAME}.xcodeproj/project.pbxproj"
sed -i '' "s/${OLD_BUNDLE_ID}/${NEW_BUNDLE_ID}/g" "${NEW_NAME}.xcodeproj/project.pbxproj"
sed -i '' "s/${OLD_TEAM_ID}/${NEW_TEAM_ID}/g" "${NEW_NAME}.xcodeproj/project.pbxproj"

# 3. Rename app directory
echo "📁 Renaming app directory..."
mv "${OLD_NAME}" "${NEW_NAME}"

# 4. Update all Swift files
echo "🔧 Updating source files..."
find "${NEW_NAME}" -name "*.swift" -type f -exec sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" {} +
find "${NEW_NAME}" -name "*.swift" -type f -exec sed -i '' "s/${OLD_BUNDLE_ID}/${NEW_BUNDLE_ID}/g" {} +

# 5. Rename main app file
echo "📝 Renaming app entry point..."
mv "${NEW_NAME}/${OLD_NAME}App.swift" "${NEW_NAME}/${NEW_NAME}App.swift"

# 6. Update test files
echo "🧪 Updating tests..."
if [ -d "${OLD_NAME}Tests" ]; then
    mv "${OLD_NAME}Tests" "${NEW_NAME}Tests"
    find "${NEW_NAME}Tests" -name "*.swift" -type f -exec sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" {} +
    find "${NEW_NAME}Tests" -name "*.swift" -type f -exec sed -i '' "s/${OLD_BUNDLE_ID}/${NEW_BUNDLE_ID}/g" {} +
fi

# 7. Update scripts
echo "📜 Updating scripts..."
find scripts -name "*.sh" -type f -exec sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" {} +
find scripts -name "*.sh" -type f -exec sed -i '' "s/${OLD_BUNDLE_ID}/${NEW_BUNDLE_ID}/g" {} +
sed -i '' "s/PROJECT=\".*\"/PROJECT=\"${NEW_NAME}.xcodeproj\"/g" scripts/build.sh
sed -i '' "s/SCHEME=\".*\"/SCHEME=\"${NEW_NAME}\"/g" scripts/build.sh
sed -i '' "s/PROJECT=\".*\"/PROJECT=\"${NEW_NAME}.xcodeproj\"/g" scripts/test.sh
sed -i '' "s/SCHEME=\".*\"/SCHEME=\"${NEW_NAME}\"/g" scripts/test.sh
sed -i '' "s/BUNDLE_ID=\".*\"/BUNDLE_ID=\"${NEW_BUNDLE_ID}\"/g" scripts/install.sh

# 8. Update README
echo "📖 Updating documentation..."
sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" README.md
sed -i '' "s/${OLD_BUNDLE_ID}/${NEW_BUNDLE_ID}/g" README.md
sed -i '' "s/${OLD_TEAM_ID}/${NEW_TEAM_ID}/g" README.md

# Update docs
find docs -name "*.md" -type f -exec sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" {} +
find docs -name "*.md" -type f -exec sed -i '' "s/${OLD_BUNDLE_ID}/${NEW_BUNDLE_ID}/g" {} +

# 9. Fresh git repo (optional)
if [ "$FRESH_GIT" = true ]; then
    echo "🗑️  Removing template git history..."
    rm -rf .git
    git init
    git add .
    git commit -m "Initial commit from iOS template"
fi

# 10. Validate with build
echo "✅ Validating configuration..."
./scripts/build.sh

echo ""
echo "🎉 Template customization complete!"
echo ""
echo "Your new project: ${NEW_NAME}"
echo "Bundle ID: ${NEW_BUNDLE_ID}"
echo "Team ID: ${NEW_TEAM_ID}"
echo ""
echo "Next steps:"
echo "  1. Update app icon in ${NEW_NAME}/Assets.xcassets/AppIcon.appiconset"
echo "  2. Customize accent color in ${NEW_NAME}/Assets.xcassets/AccentColor.colorset"
echo "  3. Update display name in ${NEW_NAME}/Info.plist (if exists)"
echo "  4. Review docs/guides/customizing-template.md for additional steps"
echo ""
echo "Build and run:"
echo "  ./scripts/install.sh"
```

**Step 2: Make executable**

```bash
chmod +x setup.sh
```

**Step 3: Commit**

```bash
git add setup.sh
git commit -m "feat: add template customization script"
```

---

### Task 20: Write Customization Guide

**Files:**
- Create: `docs/guides/customizing-template.md`

**Step 1: Create guide**

Create `docs/guides/customizing-template.md`:
```markdown
# Customizing Template Guide

Step-by-step guide to customizing this template for a new project.

## Quick Start

The fastest way to customize the template:

```bash
./setup.sh \
  --name YourApp \
  --bundle-id com.yourcompany.yourapp \
  --team-id YOUR_TEAM_ID \
  --fresh-git
```

This automates most customization steps. Continue reading for manual steps and details.

## What the Script Does

The `setup.sh` script automates:

1. ✅ Renames Xcode project
2. ✅ Updates bundle identifier throughout project
3. ✅ Updates team ID for code signing
4. ✅ Renames app entry point
5. ✅ Updates all import statements
6. ✅ Updates AppLogger subsystem
7. ✅ Updates documentation
8. ✅ Updates build scripts
9. ✅ Optionally initializes fresh git repo
10. ✅ Validates with a build

## Manual Steps

After running the script, complete these manual steps:

### 1. App Icon

Replace the app icon:

```bash
# Location
YourApp/Assets.xcassets/AppIcon.appiconset/

# Replace with your icon
# Use 1024x1024 PNG for App Store
# Xcode generates other sizes automatically
```

### 2. Accent Color

Customize the accent color:

```bash
# Location
YourApp/Assets.xcassets/AccentColor.colorset/

# Edit Contents.json or use Xcode color picker
```

### 3. Display Name

Update the display name (shown on home screen):

1. Open `YourApp.xcodeproj` in Xcode
2. Select project in navigator
3. Select app target
4. Set "Display Name" in General tab

Or edit Info.plist if it exists:
```xml
<key>CFBundleDisplayName</key>
<string>Your App</string>
```

### 4. Launch Screen

Customize launch screen if needed:

- Modify `YourApp/LaunchScreen.storyboard` (if exists)
- Or create custom launch screen view

### 5. Privacy Descriptions

Add privacy usage descriptions as needed:

Edit Info.plist to add:
- `NSCameraUsageDescription` - Camera access
- `NSPhotoLibraryUsageDescription` - Photo library access
- `NSLocationWhenInUseUsageDescription` - Location access
- etc.

### 6. Build Configurations

Review and customize build settings:

1. Open project in Xcode
2. Select project → Info tab
3. Add configurations if needed (Staging, etc.)

### 7. Code Signing

Verify code signing settings:

1. Open project in Xcode
2. Select target → Signing & Capabilities
3. Confirm team is correct
4. Enable automatic signing or configure manually

## Manual Customization (Without Script)

If you prefer manual customization:

### 1. Project Rename

```bash
# Rename project file
mv MyApp.xcodeproj YourApp.xcodeproj

# Rename app directory
mv MyApp YourApp

# Rename test directories
mv MyAppTests YourAppTests
mv MyAppUITests YourAppUITests
```

### 2. Bundle Identifier

Find and replace in all files:
```bash
find . -type f -name "*.swift" -o -name "*.pbxproj" | \
  xargs sed -i '' 's/com.example.MyApp/com.yourcompany.yourapp/g'
```

### 3. Team ID

Update in `YourApp.xcodeproj/project.pbxproj`:
```bash
sed -i '' 's/9C77FVAH99/YOUR_TEAM_ID/g' YourApp.xcodeproj/project.pbxproj
```

### 4. App Name

Find and replace in all Swift files:
```bash
find . -type f -name "*.swift" | \
  xargs sed -i '' 's/MyApp/YourApp/g'
```

### 5. Rename Main File

```bash
mv YourApp/MyAppApp.swift YourApp/YourAppApp.swift
```

### 6. Update Documentation

```bash
find docs -type f -name "*.md" | \
  xargs sed -i '' 's/MyApp/YourApp/g'
```

## Verification

After customization, verify everything works:

### 1. Build

```bash
./scripts/build.sh
```

Expected: Build succeeds without errors

### 2. Run Tests

```bash
./scripts/test.sh
```

Expected: All tests pass

### 3. Install and Launch

```bash
./scripts/install.sh
```

Expected: App installs and launches

### 4. Check Logs

```bash
/usr/bin/log stream --predicate "subsystem == 'com.yourcompany.yourapp'"
```

Expected: See startup log messages

## Common Issues

### Build Fails After Customization

**Cause:** Missed references to old name
**Fix:** Search project for old name:
```bash
grep -r "MyApp" YourApp/ --exclude-dir=build
grep -r "com.example.MyApp" YourApp/ --exclude-dir=build
```

### Code Signing Error

**Cause:** Invalid team ID
**Fix:** Verify team ID at https://developer.apple.com/account

### Tests Don't Run

**Cause:** Test target references old name
**Fix:** Update test target name in Xcode project settings

### App Won't Launch

**Cause:** Bundle ID mismatch
**Fix:** Verify bundle ID matches in:
- Project settings
- AppLogger.subsystem
- scripts/install.sh

## Git Workflow

### Option 1: Fresh Repository

Start with clean history:
```bash
./setup.sh --name YourApp --bundle-id com.company.app --team-id ABC123 --fresh-git
```

### Option 2: Fork Template

Keep connection to template:
```bash
# Clone template
git clone https://github.com/yourorg/ios-template.git your-app
cd your-app

# Customize
./setup.sh --name YourApp --bundle-id com.company.app --team-id ABC123

# Create new remote
git remote rename origin template
git remote add origin https://github.com/yourorg/your-app.git
git push -u origin main
```

Benefits:
- Can pull template updates
- Track customizations separately

### Option 3: Template Repository

Use GitHub's template feature:
1. Click "Use this template" on GitHub
2. Clone your new repo
3. Run `./setup.sh` locally

## Updating from Template

If you kept the template remote:

```bash
# Fetch template updates
git fetch template

# View changes
git diff template/main

# Merge updates (carefully!)
git merge template/main

# Resolve conflicts
# Re-run customization if needed
```

## Checklist

Complete customization checklist:

- [ ] Run `./setup.sh` with your details
- [ ] Replace app icon
- [ ] Customize accent color
- [ ] Set display name
- [ ] Add privacy descriptions
- [ ] Verify code signing
- [ ] Build successfully
- [ ] Run tests
- [ ] Install and launch app
- [ ] Verify logs show correct subsystem
- [ ] Update README with project details
- [ ] Remove/update template-specific docs
- [ ] Commit changes

## Further Reading

- [Architecture Guide](architecture.md)
- [Build Scripts](../../scripts/)
- [GitHub Template Docs](https://docs.github.com/en/repositories/creating-and-managing-repositories/creating-a-repository-from-a-template)
```

**Step 2: Commit**

```bash
git add docs/guides/customizing-template.md
git commit -m "docs: add template customization guide"
```

---

## Phase 6: Polish

### Task 21: Update README with Quick Start

**Files:**
- Modify: `README.md`

**Step 1: Add Quick Start section at top of README**

Add after the overview section in `README.md`:

```markdown
## Quick Start

### For Template Users

Customize this template for your new project:

```bash
./setup.sh \
  --name YourApp \
  --bundle-id com.yourcompany.yourapp \
  --team-id YOUR_TEAM_ID \
  --fresh-git
```

See [Customization Guide](docs/guides/customizing-template.md) for details.

### For Development

```bash
# Bootstrap environment
./scripts/bootstrap.sh

# Build and run
./scripts/install.sh

# Run tests
./scripts/test.sh
```

See [comprehensive CLI reference](#command-reference) below.
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add Quick Start section to README"
```

---

### Task 22: Add View Extensions

**Files:**
- Create: `MyApp/Shared/Extensions/View+Extensions.swift`

**Step 1: Create View extensions**

Create `MyApp/Shared/Extensions/View+Extensions.swift`:
```swift
import SwiftUI

extension View {
    /// Applies standard card styling with shadow and corner radius.
    ///
    /// - Parameters:
    ///   - cornerRadius: Corner radius value (default: medium)
    ///   - shadowRadius: Shadow radius (default: 4)
    /// - Returns: Modified view with card styling
    func cardStyle(
        cornerRadius: CGFloat = DesignConstants.CornerRadius.medium,
        shadowRadius: CGFloat = 4
    ) -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(radius: shadowRadius)
    }

    /// Applies standard padding from design system.
    ///
    /// - Parameter spacing: Spacing value from DesignConstants
    /// - Returns: Modified view with consistent padding
    func standardPadding(_ spacing: CGFloat = DesignConstants.Spacing.medium) -> some View {
        self.padding(spacing)
    }
}
```

**Step 2: Commit**

```bash
git add MyApp/Shared/Extensions/View+Extensions.swift
git commit -m "feat: add View extensions for consistent styling"
```

---

### Task 23: Add Color Extensions

**Files:**
- Create: `MyApp/Shared/Extensions/Color+Extensions.swift`

**Step 1: Create Color extensions**

Create `MyApp/Shared/Extensions/Color+Extensions.swift`:
```swift
import SwiftUI

extension Color {
    /// Standard gradient colors for the app.
    enum Gradient {
        static let start: Color = .blue
        static let end: Color = .purple
    }

    /// Semantic colors for different states.
    enum Semantic {
        static let success: Color = .green
        static let warning: Color = .orange
        static let error: Color = .red
        static let info: Color = .blue
    }
}
```

**Step 2: Update GradientBackground to use extension**

Update `MyApp/Shared/Components/GradientBackground.swift`:
```swift
import SwiftUI

/// Reusable gradient background component.
///
/// Provides a consistent gradient effect across the app.
/// Uses colors from the app's design system.
struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color.Gradient.start, Color.Gradient.end]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackground()
}
```

**Step 3: Build to verify**

```bash
xcodebuild -project MyApp.xcodeproj -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Expected: Build succeeds

**Step 4: Commit**

```bash
git add MyApp/Shared/Extensions/Color+Extensions.swift MyApp/Shared/Components/GradientBackground.swift
git commit -m "feat: add Color extensions and update GradientBackground"
```

---

### Task 24: Expand DesignSystem

**Files:**
- Create: `MyApp/Shared/DesignSystem/Typography.swift`
- Create: `MyApp/Shared/DesignSystem/Spacing.swift`

**Step 1: Create Typography**

Create `MyApp/Shared/DesignSystem/Typography.swift`:
```swift
import SwiftUI

/// Typography styles for consistent text throughout the app.
enum Typography {
    /// Standard font sizes
    enum FontSize {
        static let small: CGFloat = 12
        static let body: CGFloat = 16
        static let title: CGFloat = 20
        static let largeTitle: CGFloat = 28
    }

    /// Font weights
    enum Weight {
        static let light: Font.Weight = .light
        static let regular: Font.Weight = .regular
        static let medium: Font.Weight = .medium
        static let semibold: Font.Weight = .semibold
        static let bold: Font.Weight = .bold
    }
}

extension Font {
    /// Standard body text
    static var appBody: Font {
        .system(size: Typography.FontSize.body, weight: Typography.Weight.regular)
    }

    /// Standard title
    static var appTitle: Font {
        .system(size: Typography.FontSize.title, weight: Typography.Weight.semibold)
    }

    /// Large title
    static var appLargeTitle: Font {
        .system(size: Typography.FontSize.largeTitle, weight: Typography.Weight.bold)
    }

    /// Small caption text
    static var appCaption: Font {
        .system(size: Typography.FontSize.small, weight: Typography.Weight.regular)
    }
}
```

**Step 2: Create Spacing**

Create `MyApp/Shared/DesignSystem/Spacing.swift`:
```swift
import Foundation

/// Spacing constants for consistent layout.
///
/// Use these values instead of hardcoded numbers for spacing.
enum Spacing {
    static let tiny: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let extraLarge: CGFloat = 32
    static let huge: CGFloat = 48
}
```

**Step 3: Update DesignConstants to use Spacing**

Update `MyApp/Shared/DesignSystem/DesignConstants.swift`:
```swift
import Foundation

/// Global design constants for the app.
///
/// Centralizes spacing, sizing, and other design tokens
/// to ensure consistency across the UI.
enum DesignConstants {
    /// Standard spacing values
    /// Use Spacing enum for new code
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    /// Corner radius values
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
    }

    /// Animation durations
    enum Animation {
        static let quick: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
    }
}
```

**Step 4: Commit**

```bash
git add MyApp/Shared/DesignSystem/Typography.swift MyApp/Shared/DesignSystem/Spacing.swift MyApp/Shared/DesignSystem/DesignConstants.swift
git commit -m "feat: add Typography and Spacing to design system"
```

---

### Task 25: Final Documentation Review

**Files:**
- Create: `docs/guides/adding-features.md`
- Create: `docs/guides/swift6-concurrency.md`
- Create: `docs/patterns/view-models.md`

**Step 1: Create adding-features guide**

Create `docs/guides/adding-features.md`:
```markdown
# Adding Features Guide

Step-by-step guide to adding new features to the template.

## Overview

Features are self-contained modules in the `Features/` directory. Each feature has its own views, view models, and components.

## Feature Anatomy

```
Features/
└── YourFeature/
    ├── YourFeatureView.swift       # Main view
    ├── YourFeatureViewModel.swift  # View model
    ├── Components/                 # Feature-specific components
    │   └── YourComponent.swift
    └── README.md                   # Feature documentation
```

## Step-by-Step Guide

### 1. Create Feature Directory

```bash
mkdir -p MyApp/Features/YourFeature/Components
```

### 2. Create View Model

Create `Features/YourFeature/YourFeatureViewModel.swift`:

```swift
import Foundation
import Observation

@Observable
@MainActor
final class YourFeatureViewModel {
    private let logger = AppLogger.logger(for: .ui)

    // State
    var isLoading: Bool = false
    var errorMessage: String?

    // Actions
    func load() async {
        logger.debug("Loading YourFeature")
        isLoading = true
        defer { isLoading = false }

        // Implementation

        logger.info("YourFeature loaded successfully")
    }
}
```

### 3. Create View

Create `Features/YourFeature/YourFeatureView.swift`:

```swift
import SwiftUI

struct YourFeatureView: View {
    @State private var viewModel = YourFeatureViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                // Your UI
                Text("Your Feature")
                    .font(.appTitle)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

#Preview {
    YourFeatureView()
}
```

### 4. Add to Xcode Project

1. Open `MyApp.xcodeproj` in Xcode
2. Right-click `Features/` group
3. Add Files to "MyApp"...
4. Select your feature folder
5. Ensure "Create groups" is selected
6. Click Add

### 5. Create Tests

Create `MyAppTests/Features/YourFeature/YourFeatureViewModelTests.swift`:

```swift
import Testing
@testable import MyApp

@Suite("YourFeatureViewModel Tests")
struct YourFeatureViewModelTests {

    @Test("Loads successfully")
    @MainActor
    func testLoad() async {
        let viewModel = YourFeatureViewModel()

        #expect(viewModel.isLoading == false)

        await viewModel.load()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
}
```

### 6. Add Feature README

Create `Features/YourFeature/README.md`:

```markdown
# YourFeature

Brief description of what this feature does.

## Components

- `YourFeatureView` - Main view for this feature
- `YourFeatureViewModel` - Business logic and state management

## Dependencies

- `Core/Logging` - Logging infrastructure
- `Shared/DesignSystem` - Typography and spacing

## Usage

```swift
struct ContentView: View {
    var body: some View {
        YourFeatureView()
    }
}
```
```

### 7. Integrate into App

Update navigation to include your feature:

```swift
// In your main view or navigation
NavigationLink("Your Feature") {
    YourFeatureView()
}
```

### 8. Run Tests

```bash
./scripts/test.sh
```

### 9. Commit

```bash
git add MyApp/Features/YourFeature/
git add MyAppTests/Features/YourFeature/
git commit -m "feat: add YourFeature"
```

## Best Practices

### Do
- ✅ Keep features independent
- ✅ Use AppLogger for logging
- ✅ Follow @Observable pattern for view models
- ✅ Add tests for view models
- ✅ Use design system constants
- ✅ Document feature purpose in README

### Don't
- ❌ Import other features
- ❌ Add Core dependencies without reason
- ❌ Skip tests
- ❌ Hardcode spacing/colors
- ❌ Use global state
- ❌ Mix business logic in views

## Further Reading

- [Architecture Guide](architecture.md)
- [View Models Pattern](../patterns/view-models.md)
- [Testing Guide](testing.md)
```

**Step 2: Create swift6-concurrency guide**

Create `docs/guides/swift6-concurrency.md`:
```markdown
# Swift 6 Concurrency Guide

Comprehensive guide to Swift 6 concurrency patterns in this template.

## Overview

This template enables **complete concurrency checking** from day one. All code must compile with Swift 6's strict concurrency model.

## Project Configuration

### Xcode Settings

- **Swift Language Version**: 6.0
- **Swift Concurrency Checking**: Complete
- **Enable Actor Data-Race Safety**: Yes

### Build Settings

All warnings related to concurrency are treated as errors.

## Core Patterns

### 1. @Observable View Models

Use `@Observable` with `@MainActor` for view models:

```swift
import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    var userName: String = ""
    var isLoading: Bool = false

    func load() async {
        // MainActor-isolated automatically
        isLoading = true

        // Call async functions
        userName = await fetchUserName()

        isLoading = false
    }
}
```

**Why @MainActor:**
- Ensures UI updates happen on main thread
- Prevents data races with SwiftUI
- Makes threading explicit

### 2. Sendable Types

All shared types must be `Sendable`:

```swift
struct User: Sendable {
    let id: UUID
    let name: String
    let email: String
}

enum NetworkError: Error, Sendable {
    case invalidURL
    case requestFailed(String)
}
```

**What makes a type Sendable:**
- All properties are Sendable
- No mutable state (or properly isolated)
- Value types (struct, enum) are often Sendable
- Classes can conform if immutable or isolated

### 3. Actors for Shared State

Use actors for shared mutable state:

```swift
actor DataCache {
    private var cache: [String: Data] = [:]

    func get(_ key: String) -> Data? {
        cache[key]
    }

    func set(_ key: String, value: Data) {
        cache[key] = value
    }

    func clear() {
        cache.removeAll()
    }
}
```

**When to use actors:**
- Shared mutable state
- Background processing
- State accessed from multiple contexts

### 4. Async/Await

All async code uses async/await:

```swift
func fetchData() async throws -> Data {
    let url = URL(string: "https://api.example.com/data")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}
```

**Benefits:**
- Linear code flow
- Automatic task cancellation
- Better error handling

### 5. Task Groups

Use task groups for concurrent operations:

```swift
func fetchMultiple() async throws -> [Data] {
    try await withThrowingTaskGroup(of: Data.self) { group in
        for url in urls {
            group.addTask {
                try await self.fetch(url)
            }
        }

        var results: [Data] = []
        for try await data in group {
            results.append(data)
        }
        return results
    }
}
```

## Common Patterns

### Loading Data in Views

```swift
struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Text(viewModel.userName)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
```

**Use `.task` for:**
- Initial data loading
- Automatic cancellation on disappear

### Background Work

```swift
@MainActor
final class ViewModel {
    func processData() async {
        // Switch to background
        let result = await Task.detached {
            // Heavy computation
            heavyWork()
        }.value

        // Back on MainActor
        self.updateUI(result)
    }
}
```

### Actor Services

```swift
actor APIClient {
    private let logger = AppLogger.logger(for: .networking)
    private var session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: String) async throws -> T {
        logger.debug("Request: \(endpoint)")

        let url = URL(string: endpoint)!
        let (data, _) = try await session.data(from: url)

        let decoded = try JSONDecoder().decode(T.self, from: data)
        logger.info("Request completed")

        return decoded
    }
}
```

## Troubleshooting

### "Sending 'self' risks causing data races"

**Problem:** Passing non-Sendable type across isolation boundaries

**Solution:** Make type Sendable or use actor isolation

```swift
// Before
class Model {  // Not Sendable
    var data: String
}

// After
struct Model: Sendable {
    let data: String
}
```

### "Main actor-isolated property cannot be mutated from a non-isolated context"

**Problem:** Updating MainActor property from background

**Solution:** Use await or @MainActor

```swift
// Before
func update() {
    viewModel.data = newData  // Error
}

// After
@MainActor
func update() {
    viewModel.data = newData  // OK
}

// Or
func update() async {
    await MainActor.run {
        viewModel.data = newData
    }
}
```

### "Call to main actor-isolated function in a synchronous nonisolated context"

**Problem:** Calling MainActor function from background

**Solution:** Make caller async and await

```swift
// Before
func doWork() {
    updateUI()  // Error: updateUI is @MainActor
}

// After
func doWork() async {
    await updateUI()  // OK
}
```

## Testing with Concurrency

### Testing Async Functions

```swift
@Test("Async operation completes")
func testAsync() async throws {
    let result = await asyncFunction()
    #expect(result != nil)
}
```

### Testing Actors

```swift
@Test("Actor maintains isolation")
func testActor() async {
    let cache = DataCache()

    await cache.set("key", value: data)
    let retrieved = await cache.get("key")

    #expect(retrieved == data)
}
```

### Testing MainActor Code

```swift
@Test("Updates on MainActor")
@MainActor
func testMainActor() async {
    let viewModel = ProfileViewModel()
    await viewModel.load()
    #expect(viewModel.isLoading == false)
}
```

## Migration from Swift 5

### Classes → Sendable Structs

```swift
// Before
class User {
    var name: String
}

// After
struct User: Sendable {
    let name: String
}
```

### @ObservableObject → @Observable

```swift
// Before
class ViewModel: ObservableObject {
    @Published var data: String = ""
}

// After
@Observable
@MainActor
final class ViewModel {
    var data: String = ""
}
```

### Completion Handlers → Async/Await

```swift
// Before
func fetch(completion: @escaping (Result<Data, Error>) -> Void) {
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let error = error {
            completion(.failure(error))
        } else if let data = data {
            completion(.success(data))
        }
    }.resume()
}

// After
func fetch() async throws -> Data {
    let (data, _) = try await URLSession.shared.data(from: url)
    return data
}
```

## Best Practices

### Do
- ✅ Use @MainActor for view models
- ✅ Make shared types Sendable
- ✅ Use actors for shared mutable state
- ✅ Prefer async/await over callbacks
- ✅ Let compiler enforce correctness

### Don't
- ❌ Use @unchecked Sendable unless absolutely necessary
- ❌ Use nonisolated(unsafe) to bypass checks
- ❌ Share mutable state without isolation
- ❌ Mix old and new concurrency models
- ❌ Ignore concurrency warnings

## Further Reading

- [Swift Concurrency Documentation](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Migration Guide](https://www.swift.org/migration/documentation/swift-6-concurrency-migration-guide/)
- [Architecture Guide](architecture.md)
```

**Step 3: Create view-models pattern guide**

Create `docs/patterns/view-models.md`:
```markdown
# View Models Pattern

Guide to implementing view models with @Observable in Swift 6.

## Overview

View models manage state and business logic for views. This template uses Swift's `@Observable` macro for reactive state management.

## Basic Pattern

```swift
import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel {
    // State
    var userName: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    // Dependencies
    private let logger = AppLogger.logger(for: .ui)

    // Actions
    func load() async {
        logger.debug("Loading profile")
        isLoading = true
        defer { isLoading = false }

        do {
            userName = try await fetchUserName()
            logger.info("Profile loaded successfully")
        } catch {
            errorMessage = error.localizedDescription
            logger.error("Failed to load profile: \(error)")
        }
    }
}
```

## View Integration

```swift
struct ProfileView: View {
    @State private var viewModel = ProfileViewModel()

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                Text(viewModel.userName)
                    .font(.appTitle)
            }
        }
        .task {
            await viewModel.load()
        }
    }
}
```

## Key Components

### 1. @Observable Macro

Makes properties automatically observable:

```swift
@Observable
final class ViewModel {
    var count: Int = 0  // Automatically observable
}
```

### 2. @MainActor Isolation

Ensures UI updates happen on main thread:

```swift
@Observable
@MainActor  // All properties and methods on main thread
final class ViewModel {
    var data: String = ""

    func update() {
        // Automatically on MainActor
        self.data = "Updated"
    }
}
```

### 3. State Properties

Public var for view binding:

```swift
@Observable
@MainActor
final class ViewModel {
    var isLoading: Bool = false
    var items: [Item] = []
    var selectedItem: Item?
}
```

### 4. Actions

Public async methods:

```swift
func load() async {
    isLoading = true
    defer { isLoading = false }

    items = await fetchItems()
}

func select(_ item: Item) {
    selectedItem = item
}
```

## Common Patterns

### Loading State

```swift
@Observable
@MainActor
final class ViewModel {
    enum LoadingState {
        case idle
        case loading
        case loaded
        case failed(Error)
    }

    var state: LoadingState = .idle
    var data: [Item] = []

    func load() async {
        state = .loading

        do {
            data = try await fetchData()
            state = .loaded
        } catch {
            state = .failed(error)
        }
    }
}
```

### Pagination

```swift
@Observable
@MainActor
final class ListViewModel {
    var items: [Item] = []
    var isLoadingMore: Bool = false
    var hasMore: Bool = true

    private var page: Int = 0

    func loadNext() async {
        guard !isLoadingMore && hasMore else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        let newItems = await fetchPage(page)
        items.append(contentsOf: newItems)
        hasMore = !newItems.isEmpty
        page += 1
    }
}
```

### Search

```swift
@Observable
@MainActor
final class SearchViewModel {
    var query: String = "" {
        didSet { performSearch() }
    }
    var results: [Item] = []
    var isSearching: Bool = false

    private var searchTask: Task<Void, Never>?

    private func performSearch() {
        searchTask?.cancel()

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))  // Debounce

            guard !Task.isCancelled else { return }

            isSearching = true
            defer { isSearching = false }

            results = await search(query)
        }
    }
}
```

### Form Validation

```swift
@Observable
@MainActor
final class FormViewModel {
    var email: String = ""
    var password: String = ""

    var isValid: Bool {
        isValidEmail(email) && password.count >= 8
    }

    var emailError: String? {
        guard !email.isEmpty else { return nil }
        return isValidEmail(email) ? nil : "Invalid email"
    }

    func submit() async throws {
        guard isValid else { return }
        try await submitForm(email: email, password: password)
    }
}
```

## Testing View Models

```swift
import Testing
@testable import MyApp

@Suite("ProfileViewModel Tests")
struct ProfileViewModelTests {

    @Test("Loads profile successfully")
    @MainActor
    func testLoad() async {
        let viewModel = ProfileViewModel()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.userName == "")

        await viewModel.load()

        #expect(viewModel.isLoading == false)
        #expect(viewModel.userName != "")
        #expect(viewModel.errorMessage == nil)
    }

    @Test("Handles load error")
    @MainActor
    func testLoadError() async {
        let viewModel = ProfileViewModel(shouldFail: true)

        await viewModel.load()

        #expect(viewModel.errorMessage != nil)
    }
}
```

## Best Practices

### Do
- ✅ Use @Observable @MainActor for all view models
- ✅ Keep business logic in view model
- ✅ Use async/await for operations
- ✅ Provide loading and error states
- ✅ Log significant actions
- ✅ Make view models testable

### Don't
- ❌ Put UI code in view models
- ❌ Access view models from background threads
- ❌ Create view models as singletons
- ❌ Store views in view models
- ❌ Use @Published (use @Observable instead)
- ❌ Make view models ObservableObject

## Migration from ObservableObject

```swift
// Before (Swift 5)
class ViewModel: ObservableObject {
    @Published var data: String = ""

    func update() {
        DispatchQueue.main.async {
            self.data = "Updated"
        }
    }
}

// After (Swift 6)
@Observable
@MainActor
final class ViewModel {
    var data: String = ""

    func update() {
        self.data = "Updated"  // Automatically on MainActor
    }
}
```

## Further Reading

- [Swift 6 Concurrency Guide](../guides/swift6-concurrency.md)
- [Testing Guide](../guides/testing.md)
- [Architecture Guide](../guides/architecture.md)
```

**Step 4: Commit**

```bash
git add docs/guides/adding-features.md docs/guides/swift6-concurrency.md docs/patterns/view-models.md
git commit -m "docs: add comprehensive feature, concurrency, and pattern guides"
```

---

## Final Steps

### Task 26: Final Build and Test

**Step 1: Clean build**

```bash
rm -rf build
./scripts/build.sh
```

Expected: Build succeeds

**Step 2: Run all tests**

```bash
./scripts/test.sh
```

Expected: All tests pass

**Step 3: Install and verify**

```bash
./scripts/install.sh
```

Expected: App installs and launches

**Step 4: Check logs**

```bash
/usr/bin/log stream --level debug --predicate "subsystem == 'com.example.MyApp'" &
LOG_PID=$!
sleep 5
kill $LOG_PID
```

Expected: See startup logs from AppLogger

---

### Task 27: Final Commit

**Step 1: Review all changes**

```bash
git status
git diff main
```

**Step 2: Final commit**

```bash
git add -A
git commit -m "feat: complete iOS template implementation

Implements comprehensive iOS template with:
- Feature-based architecture (Core, Features, Shared)
- AppLogger system with type-safe categories
- Swift Testing framework with examples
- Comprehensive documentation (guides, patterns)
- CLI build/test/install scripts
- Template customization automation (setup.sh)
- Design system (Typography, Spacing, Colors)
- Swift 6 strict concurrency throughout

All features documented and tested.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

---

## Success Criteria

Verify all criteria are met:

- [ ] All code compiles with Swift 6 complete concurrency checking
- [ ] All tests pass via CLI (`./scripts/test.sh`)
- [ ] Template can be customized via `./setup.sh` in <2 minutes
- [ ] Documentation is comprehensive and clear
- [ ] Project builds and runs via CLI without Xcode IDE
- [ ] Feature-based structure demonstrated with working example
- [ ] Logging infrastructure used throughout codebase
- [ ] Swift Testing examples cover common patterns

---

## Execution Notes

This plan is designed for bite-sized execution (2-5 minutes per step). Each task:
- Has explicit file paths
- Includes complete code
- Specifies exact commands
- Includes verification steps
- Ends with a commit

Follow tasks in order. All dependencies are handled sequentially.
