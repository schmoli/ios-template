# Customizing the Template

This guide walks you through adapting this template for your new project.

## Quick Start (Automated)

The fastest way to customize the template:

```bash
# 1. Bootstrap development environment
./scripts/bootstrap.sh

# 2. Run customization script
./scripts/setup.sh

# 3. Open in Xcode
open YourApp.xcodeproj

# 4. Build and run
./scripts/build.sh
./scripts/install.sh
```

The setup script will prompt you for:
- **App Name** (e.g., "PhotoEditor") - replaces "MyApp" everywhere
- **Bundle ID** (e.g., "com.yourcompany.PhotoEditor") - replaces "com.example.MyApp"

## Manual Customization

If you prefer manual control:

### 1. Rename the App

**Update Xcode Project:**
- Select `MyApp.xcodeproj` in Xcode
- Select the project in the navigator
- In Identity Inspector, change:
  - Display Name: `MyApp` → `YourApp`
  - Bundle Identifier: `com.example.MyApp` → `com.yourcompany.YourApp`

**Rename Directories:**
```bash
mv MyApp YourApp
mv MyAppTests YourAppTests
mv MyApp.xcodeproj YourApp.xcodeproj
```

### 2. Update Logger Subsystem

The logger uses your bundle ID as the subsystem. Update:

**File:** `YourApp/Core/Logging/AppLogger.swift`

```swift
enum AppLogger {
    static let subsystem = "com.yourcompany.YourApp"  // ← Change this

    static func logger(for category: LogCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }
}
```

### 3. Update Launch Logging

**File:** `YourApp/YourAppApp.swift`

```swift
init() {
    logger.log("🚀 YourApp starting up on iOS 26!")  // ← Change this
}
```

### 4. Update Install Script

**File:** `scripts/install.sh`

Update the app name and bundle ID:

```bash
# Find app bundle
APP_PATH=$(find ./build -name "YourApp.app" -type d | head -1)

if [ -z "$APP_PATH" ]; then
    echo "❌ YourApp.app not found. Run ./scripts/build.sh first"
    exit 1
fi

# Install and launch
xcrun simctl install "$SIM_UDID" "$APP_PATH"
xcrun simctl launch "$SIM_UDID" com.yourcompany.YourApp
```

### 5. Clean Build Artifacts

```bash
rm -rf build/
rm -rf DerivedData/
```

## What's Included

After customization, your project has:

### Core Infrastructure
- **Logging:** `Core/Logging/` - Type-safe logger with categories
- **Networking:** `Core/Networking/` - TODO: Add API client
- **Persistence:** `Core/Persistence/` - TODO: Add data storage

### Features
- **Welcome Screen:** `Features/Welcome/` - Example feature module
- Add your features here in `Features/YourFeature/`

### Shared Code
- **Components:** `Shared/Components/` - Reusable UI (GradientBackground)
- **DesignSystem:** `Shared/DesignSystem/` - Design tokens
- **Extensions:** `Shared/Extensions/` - Swift extensions
- **Utilities:** `Shared/Utilities/` - Helper functions

### Testing
- **Unit Tests:** `YourAppTests/` - Swift Testing framework
- **Test Helpers:** `YourAppTests/TestHelpers/` - Shared utilities
- **Run Tests:** `scripts/test.sh` or Cmd+U in Xcode

### Documentation
- **Architecture:** `docs/guides/architecture.md` - Project structure, patterns
- **Logging:** `docs/guides/logging.md` - How to use AppLogger
- **Testing:** `docs/guides/testing.md` - Swift Testing framework setup

### Build Scripts
- **Build:** `scripts/build.sh [Debug|Release]` - Build the app
- **Test:** `scripts/test.sh` - Run tests
- **Install:** `scripts/install.sh` - Install and launch on simulator
- **Bootstrap:** `scripts/bootstrap.sh` - Set up development environment

## Next Steps

### 1. Update Welcome Screen

**File:** `YourApp/Features/Welcome/WelcomeView.swift`

Replace the placeholder content with your actual welcome screen:

```swift
struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            VStack {
                // Your welcome content here
                Text("Welcome to YourApp!")
                    .font(.largeTitle)
            }
            .navigationTitle("Welcome")
        }
    }
}
```

### 2. Add Your First Feature

Create a new feature module:

```bash
mkdir -p YourApp/Features/YourFeature/Components
```

**File:** `YourApp/Features/YourFeature/YourFeatureView.swift`

```swift
import SwiftUI

struct YourFeatureView: View {
    var body: some View {
        Text("Your Feature")
    }
}
```

Add to Xcode:
- Right-click `YourApp` in project navigator
- Add Files to "YourApp"
- Select `Features/YourFeature` directory

### 3. Add Networking (Optional)

If your app needs API calls:

```bash
mkdir -p YourApp/Core/Networking
```

See `docs/guides/architecture.md` for patterns.

### 4. Add Persistence (Optional)

If your app needs data storage:

```bash
mkdir -p YourApp/Core/Persistence
```

Consider SwiftData for modern Swift 6 approach.

### 5. Add Tests

Use Swift Testing framework to add tests for your features. See `docs/guides/testing.md` for patterns and examples.

Run tests: `./scripts/test.sh` or Cmd+U in Xcode

## Customization Checklist

- [ ] Run `./scripts/setup.sh` or rename manually
- [ ] Update logger subsystem in `AppLogger.swift`
- [ ] Update launch message in `YourAppApp.swift`
- [ ] Update install script bundle ID
- [ ] Build and test: `./scripts/build.sh && ./scripts/install.sh`
- [ ] Replace WelcomeView with your content
- [ ] Remove or keep example GradientBackground
- [ ] Add your first feature in `Features/`
- [ ] Commit: `git commit -m "chore: customize template for YourApp"`
- [ ] (Optional) Configure test target in Xcode
- [ ] (Optional) Add networking in `Core/Networking/`
- [ ] (Optional) Add persistence in `Core/Persistence/`

## Template Philosophy

**What's Included:**
- Essential structure every app needs
- Modern Swift 6 concurrency patterns
- Feature-based architecture
- Production-ready logging

**What's Not Included (You Add):**
- Domain-specific features
- Networking layer (your API is unique)
- Data models (your data is unique)
- Business logic

**Why This Approach:**
- ✅ Get started fast with solid foundation
- ✅ Avoid over-engineering
- ✅ Add what you need, when you need it
- ✅ YAGNI (You Aren't Gonna Need It) respected

## Getting Help

- **Architecture:** See `docs/guides/architecture.md`
- **Logging:** See `docs/guides/logging.md`
- **Testing:** See `docs/guides/testing.md`
- **Issues:** Check Xcode build errors first, then review docs
