# MyApp - iOS 26 Template Project

Modern iOS app template targeting iOS 26 with best practices and CLI-first development workflow.

## Overview

This project serves as a template for creating new iOS apps with:
- iOS 26 SDK support (Xcode 26.2+)
- SwiftUI lifecycle
- Swift 6.0 with strict concurrency
- Organized project structure (Views, Models)
- Built-in logging with `os.log`
- CLI-first workflow (no Xcode IDE required)

## Future Vision

**App Template System**: Clone this repo for new projects with automated customization:
- Replace bundle identifier: `com.example.MyApp` → `com.yourcompany.YourApp`
- Update project name throughout file structure
- Customize team ID and signing
- Script-driven setup for consistency
- Agent-compatible initialization

## Prerequisites

- **Xcode 26.2+** (iOS 26 SDK required for April 2026 App Store submissions)
- macOS with command line tools installed
- iOS 26 simulator (comes with Xcode 26)

## Project Structure

```
MyApp/
├── MyApp/
│   ├── MyAppApp.swift          # App entry point with startup logging
│   ├── ContentView.swift        # Main view
│   ├── Views/
│   │   └── Components/
│   │       └── GradientBackground.swift
│   ├── Models/
│   │   └── DesignConstants.swift
│   └── Assets.xcassets/        # Asset catalog
├── MyApp.xcodeproj/            # Xcode project
└── build/                      # Build output (gitignored)
```

## Build Settings

- **Bundle ID**: `com.example.MyApp`
- **Deployment Target**: iOS 26.0
- **Swift Version**: 6.0
- **Team ID**: `9C77FVAH99` (update for your team)

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

## Future Template Features

### Planned Enhancements

- **Setup Script**: `./setup.sh --bundle-id com.company.app --name MyApp`
- **CI/CD Integration**: GitHub Actions workflow for automated builds
- **Testing Suite**: XCTest integration with sample UI tests
- **Code Quality**: SwiftLint configuration
- **Documentation**: DocC integration for API docs
- **Fastlane**: Lane for screenshots, beta deployment
- **Design System**: Expanded DesignConstants and theme support
- **Networking Layer**: Template API client with async/await
- **Persistence**: SwiftData models and migration examples

### Template Customization Points

When cloning for new projects, update:

1. **Bundle Identifier**: `com.example.MyApp` → `com.yourcompany.YourApp`
2. **Team ID**: `9C77FVAH99` in `project.pbxproj`
3. **App Name**: `MyApp` throughout project
4. **Subsystem**: `com.example.MyApp` in logging code
5. **Display Name**: Info.plist configuration
6. **Assets**: Replace AppIcon and AccentColor

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
