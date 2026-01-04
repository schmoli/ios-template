# MyApp - iOS 26 Template Project

Production-ready iOS template with Swift 6, feature-based architecture, and automation scripts.

## Quick Start

Get started in 60 seconds:

```bash
# 1. Clone this template
git clone <your-template-repo> YourApp
cd YourApp

# 2. Bootstrap environment
./scripts/bootstrap.sh

# 3. Customize for your project
./scripts/setup.sh
# → Prompts for: App Name, Bundle ID

# 4. Build and run
./scripts/build.sh
./scripts/install.sh
```

## What's Included

### ✅ Core Infrastructure
- **Logging System** - Type-safe AppLogger with categories (`Core/Logging/`)
- **Feature Architecture** - Feature-based organization (`Features/`)
- **Design System** - Reusable components and tokens (`Shared/`)
- **Swift 6 Strict Concurrency** - Modern async/await patterns
- **Build Scripts** - Automated build, test, install

### ✅ Documentation
- **Architecture Guide** - Feature modules, dependency injection, patterns
- **Logging Guide** - Using AppLogger, log levels, viewing logs
- **Testing Guide** - Swift Testing setup (⚠️ TODO: needs Xcode config)
- **Customization Guide** - How to adapt this template

### ✅ Development Tools
- `scripts/build.sh` - Build for simulator
- `scripts/test.sh` - Run tests (TODO: test target config)
- `scripts/install.sh` - Install and launch on simulator
- `scripts/bootstrap.sh` - Set up development environment
- `scripts/setup.sh` - Customize template for your project

### 📋 TODO (Add When Needed)
- Networking layer (`Core/Networking/`)
- Persistence layer (`Core/Persistence/`)
- Test target configuration in Xcode

## Template Philosophy

**Included:** Essential structure every app needs
- Feature-based architecture
- Centralized logging
- Swift 6 concurrency patterns
- Build automation

**Not Included:** Domain-specific code you'll customize
- API client (your endpoints are unique)
- Data models (your domain is unique)
- Feature implementations (your features are unique)

**Why:** Start fast with solid foundation, add what you need when you need it. YAGNI respected.

## Prerequisites

- **Xcode 26.2+** (iOS 26 SDK required for April 2026 App Store submissions)
- macOS with command line tools installed
- iOS 26 simulator (comes with Xcode 26)

## Project Structure

```
MyApp/
├── MyApp/
│   ├── MyAppApp.swift              # App entry point
│   ├── Core/                       # Foundation systems
│   │   ├── Logging/                # AppLogger, LogCategory
│   │   ├── Networking/             # TODO: Add API client
│   │   └── Persistence/            # TODO: Add data storage
│   ├── Features/                   # Feature modules
│   │   └── Welcome/                # Example feature
│   │       ├── WelcomeView.swift
│   │       └── Components/
│   ├── Shared/                     # Reusable code
│   │   ├── Components/             # UI components
│   │   ├── DesignSystem/           # Design tokens
│   │   ├── Extensions/             # Swift extensions
│   │   └── Utilities/              # Helpers
│   └── Assets.xcassets/
├── MyAppTests/                     # TODO: Configure in Xcode
├── docs/                           # Documentation
│   ├── guides/                     # How-to guides
│   └── patterns/                   # Code patterns
├── scripts/                        # Build automation
└── MyApp.xcodeproj/

```

**See:** `docs/guides/architecture.md` for detailed architecture explanation.

## Build Settings

- **Bundle ID**: `com.example.MyApp` (change with `setup.sh`)
- **Deployment Target**: iOS 26.0
- **Swift Version**: 6.0
- **Concurrency**: Strict mode (complete checking)

---

# Command Reference

## Simulator Management

### List Available Simulators

```bash
# List all simulators
xcrun simctl list devices

# List as JSON (better for parsing)
xcrun simctl list devices --json

# List only iOS 26 simulators
xcrun simctl list devices --json | jq -r '.devices | to_entries[] | select(.key | contains("iOS-26")) | .value[] | select(.isAvailable == true) | "\(.name) (\(.udid))"'
```

### Boot/Shutdown Simulator

```bash
# Get simulator UDID (example)
UDID="809DBB84-2D9B-4111-86EA-133B1440DE5A"  # iPhone 17

# Boot simulator
xcrun simctl boot $UDID

# Boot (ignore if already running)
xcrun simctl boot $UDID 2>/dev/null || true

# Shutdown simulator
xcrun simctl shutdown $UDID

# Shutdown all simulators
xcrun simctl shutdown all
```

### Check Simulator Status

```bash
# Show booted simulators
xcrun simctl list devices | grep Booted

# Open Simulator.app (makes it visible)
open -a Simulator
```

---

## Building the App

### Build for Simulator (Debug)

```bash
# Set variables
UDID="809DBB84-2D9B-4111-86EA-133B1440DE5A"  # Your simulator UDID

# Clean and build
xcodebuild \
  -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination "platform=iOS Simulator,id=$UDID" \
  -configuration Debug \
  -derivedDataPath ./build \
  clean build
```

### Build Only (No Clean)

```bash
# Faster incremental build
xcodebuild \
  -project MyApp.xcodeproj \
  -scheme MyApp \
  -destination "platform=iOS Simulator,id=$UDID" \
  -configuration Debug \
  -derivedDataPath ./build \
  build
```

### List Available Schemes

```bash
# Show all schemes in project
xcodebuild -project MyApp.xcodeproj -list

# Show build settings
xcodebuild \
  -project MyApp.xcodeproj \
  -scheme MyApp \
  -showBuildSettings
```

### Show Available Destinations

```bash
# List all valid destinations for this project
xcodebuild \
  -project MyApp.xcodeproj \
  -scheme MyApp \
  -showDestinations
```

---

## Installing and Launching

### Install App on Simulator

```bash
# Find built .app bundle
APP_PATH="build/Build/Products/Debug-iphonesimulator/MyApp.app"

# Install on simulator
xcrun simctl install $UDID "$APP_PATH"
```

### Launch App

```bash
BUNDLE_ID="com.example.MyApp"

# Launch app (returns immediately with PID)
xcrun simctl launch $UDID $BUNDLE_ID

# Launch with console output (blocks and streams logs)
xcrun simctl launch --console $UDID $BUNDLE_ID
```

### Terminate App

```bash
# Stop running app
xcrun simctl terminate $UDID $BUNDLE_ID

# Terminate (ignore errors if not running)
xcrun simctl terminate $UDID $BUNDLE_ID 2>/dev/null || true
```

### Uninstall App

```bash
# Remove app from simulator
xcrun simctl uninstall $UDID $BUNDLE_ID
```

---

## Screenshots and Media

### Take Screenshot

```bash
# Capture screenshot to file
xcrun simctl io $UDID screenshot /tmp/screenshot.png

# With custom path
xcrun simctl io $UDID screenshot ~/Desktop/myapp-screenshot.png
```

### Record Video

```bash
# Start recording (run in background)
xcrun simctl io $UDID recordVideo /tmp/recording.mov &
RECORDING_PID=$!

# Stop recording
kill $RECORDING_PID
```

---

## Log Streaming

### Stream App Logs (Recommended Pattern)

```bash
# Start log stream in background
/usr/bin/log stream \
  --level debug \
  --predicate "subsystem == 'com.example.MyApp'" &
LOG_PID=$!

# Launch app (returns immediately)
xcrun simctl launch $UDID $BUNDLE_ID

# Watch logs in real-time...

# Stop log stream when done
kill $LOG_PID
```

### Alternative: Filter by Process Name

```bash
/usr/bin/log stream \
  --level debug \
  --predicate 'processImagePath CONTAINS "MyApp"'
```

### View System Log

```bash
# Stream all simulator logs
xcrun simctl spawn $UDID log stream

# Stream with filtering
xcrun simctl spawn $UDID log stream \
  --predicate 'eventMessage contains "MyApp"'
```

---

## Complete Workflow Examples

### Quick Build & Run

```bash
# Set variables
UDID="809DBB84-2D9B-4111-86EA-133B1440DE5A"
BUNDLE_ID="com.example.MyApp"
APP_PATH="build/Build/Products/Debug-iphonesimulator/MyApp.app"

# 1. Boot simulator (if needed)
xcrun simctl boot $UDID 2>/dev/null || true

# 2. Build app
xcodebuild -project MyApp.xcodeproj -scheme MyApp \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath ./build build

# 3. Install app
xcrun simctl install $UDID "$APP_PATH"

# 4. Launch app
xcrun simctl launch $UDID $BUNDLE_ID
```

### Build, Launch, and Monitor Logs

```bash
# 1. Start log streaming in background
/usr/bin/log stream --level debug \
  --predicate "subsystem == 'com.example.MyApp'" > /tmp/app-logs.txt &
LOG_PID=$!

# 2. Boot simulator
xcrun simctl boot $UDID 2>/dev/null || true

# 3. Build and install
xcodebuild -project MyApp.xcodeproj -scheme MyApp \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath ./build build
xcrun simctl install $UDID "$APP_PATH"

# 4. Launch
xcrun simctl launch $UDID $BUNDLE_ID

# 5. Take screenshot after 2 seconds
sleep 2
xcrun simctl io $UDID screenshot /tmp/launch-screenshot.png

# 6. View logs
tail -f /tmp/app-logs.txt

# 7. Cleanup (Ctrl+C to stop tail, then):
kill $LOG_PID
```

### Automated Testing Loop

```bash
# Rebuild, reinstall, relaunch
xcrun simctl terminate $UDID $BUNDLE_ID 2>/dev/null || true
xcodebuild -project MyApp.xcodeproj -scheme MyApp \
  -destination "platform=iOS Simulator,id=$UDID" \
  -derivedDataPath ./build build && \
xcrun simctl install $UDID "$APP_PATH" && \
xcrun simctl launch $UDID $BUNDLE_ID
```

---

## Debugging Commands

### List Installed Apps

```bash
# Show all apps on simulator
xcrun simctl listapps $UDID
```

### Get App Container Path

```bash
# Find app data directory
xcrun simctl get_app_container $UDID $BUNDLE_ID
```

### Privacy Permissions

```bash
# Grant photo library access
xcrun simctl privacy $UDID grant photos $BUNDLE_ID

# Grant location access
xcrun simctl privacy $UDID grant location $BUNDLE_ID

# Reset all permissions
xcrun simctl privacy $UDID reset all $BUNDLE_ID
```

### Open URL in App

```bash
# Launch app with URL scheme
xcrun simctl openurl $UDID "myapp://deeplink"
```

---

## Environment Variables

### Useful Variables for Scripts

```bash
# Project settings
export XCODE_PROJECT="MyApp.xcodeproj"
export XCODE_SCHEME="MyApp"
export BUNDLE_ID="com.example.MyApp"
export DERIVED_DATA_PATH="./build"

# Simulator settings
export SIM_UDID="809DBB84-2D9B-4111-86EA-133B1440DE5A"
export SIM_NAME="iPhone 17"

# Paths
export APP_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphonesimulator/MyApp.app"
```

---

## Documentation

- **Quick Start** - This README
- **Architecture** - `docs/guides/architecture.md` - Feature modules, patterns, Swift 6
- **Logging** - `docs/guides/logging.md` - AppLogger usage, categories, best practices
- **Design System** - `docs/guides/design-system.md` - Design tokens and extensions
- **Testing** - `docs/guides/testing.md` - Swift Testing setup (TODO: Xcode config)
- **Customization** - `docs/guides/customization.md` - Adapting the template
- **Commit Standards** - `docs/COMMIT_STANDARDS.md` - Conventional commits, semantic versioning

## Next Steps After Setup

1. **Update WelcomeView** - Replace with your actual welcome screen
2. **Add Your First Feature** - Create `Features/YourFeature/YourFeatureView.swift`
3. **Add Networking (If Needed)** - Implement in `Core/Networking/`
4. **Add Persistence (If Needed)** - Implement in `Core/Persistence/`
5. **Configure Tests** - Manual Xcode setup (see `docs/guides/testing.md`)

**See:** `docs/guides/customization.md` for detailed next steps.

## Future Enhancements

Optional additions for production apps:

- ✅ **Setup Script** - Implemented in `scripts/setup.sh`
- ✅ **Feature Architecture** - Implemented
- ✅ **Documentation System** - Guides in `docs/`
- ✅ **Build Automation** - Scripts in `scripts/`
- 📋 **CI/CD Integration** - GitHub Actions workflow
- 📋 **Code Quality** - SwiftLint configuration
- 📋 **DocC Integration** - API documentation
- 📋 **Fastlane** - Screenshot/beta deployment lanes

---

## Tips & Best Practices

### Performance

- Use `build` instead of `clean build` for faster iteration
- Keep simulator booted during development
- Use `-derivedDataPath` to isolate build artifacts

### Logging

- Use structured logging: `Logger(subsystem: category:)`
- Filter logs by subsystem for cleaner output
- Run log streaming in background, launch app separately

### Workflow Optimization

- Create shell aliases for common commands
- Use environment variables for reusable values
- Script repetitive build-install-launch cycles

### Troubleshooting

- If build fails: Check Xcode version matches iOS SDK requirement
- If simulator won't boot: `xcrun simctl shutdown all && xcrun simctl boot $UDID`
- If app won't install: Check bundle ID matches in app and install command
- If logs are empty: Verify subsystem string matches Logger configuration

---

## Resources

- [iOS 26 Release Notes](https://developer.apple.com/documentation/ios-ipados-release-notes/ios-ipados-26-release-notes)
- [Xcode 26 Release Notes](https://developer.apple.com/documentation/xcode-release-notes/xcode-26-release-notes)
- [simctl Documentation](https://developer.apple.com/library/archive/documentation/IDEs/Conceptual/iOS_Simulator_Guide/InteractingwiththeiOSSimulator/InteractingwiththeiOSSimulator.html)
- [xcodebuild Man Page](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)

---

**Generated with iOS 26 SDK | Xcode 26.2 | Swift 6.0**
