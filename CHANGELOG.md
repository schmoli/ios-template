# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2026-01-05

### Added

**Core Infrastructure**
- **SecureStorage** - Keychain wrapper for secure token/credential storage
  - `SecureStorageProtocol` with save/load/delete/exists operations
  - `KeychainSecureStorage` actor-based implementation
  - `MockSecureStorage` for testing
  - Type-safe with Codable support
  - Comprehensive error types
  - 6 tests covering all operations

- **BiometricAuth** - Face ID/Touch ID/Optic ID authentication wrapper
  - `BiometricAuthProtocol` with authenticate/availability checks
  - `LocalBiometricAuth` implementation wrapping LocalAuthentication
  - `MockBiometricAuth` for testing
  - Biometric type detection (Face ID/Touch ID/Optic ID)
  - Structured error handling
  - 6 tests covering all biometric types

- **AppLifecycle** - Centralized app state change hooks
  - `AppLifecycleProtocol` with onForeground/onBackground/onInactive/onAppear
  - `AppLifecycleManager` observing ScenePhase changes
  - `MockAppLifecycle` for testing
  - Parallel handler execution
  - First-appear detection
  - 7 tests using Swift Testing confirmation pattern

- **Persistence** - SwiftData wrapper for data storage
  - `PersistenceProtocol` exposing ModelContainer
  - `SwiftDataPersistence` actor-based implementation
  - `MockPersistence` with in-memory container for testing
  - File-backed storage with in-memory fallback
  - Thread-safe save operations
  - 4 tests with @Model integration

**Documentation**
- `docs/guides/security.md` - Keychain usage, error handling, migration patterns
- `docs/guides/biometric-auth.md` - Biometric flows, error cases, privacy setup
- `docs/guides/lifecycle.md` - App state hooks, common patterns, testing
- `docs/guides/persistence.md` - SwiftData models, queries, relationships, CRUD

### Changed

- Updated `docs/guides/architecture.md` with all 4 new Core systems
- Updated `README.md` Core Infrastructure and Documentation sections

### Technical Details

- All systems follow protocol-based pattern (Protocol → Implementation → Mock → Tests)
- Swift 6 strict concurrency compliant throughout
- Actor isolation for thread safety
- Sendable conformance for all shared types
- 26 new Swift files across 4 Core systems
- 10 new test files with 23 new tests (55 total passing)
- 1,484+ lines of documentation

## [0.1.2] - 2026-01-04

### Added

**Documentation**
- Added `CLAUDE.md` with feature development workflow principles
  - Prove don't promise (build, test, launch verification)
  - Preview-driven UI iteration (dark mode first)
  - Tests for correctness, eyes for quality
  - Report outcomes not code
  - Small steps always verified
  - Ask before not after
  - Always leave it working
  - Testing decision criteria

## [0.1.1] - 2026-01-04

### Fixed

**Documentation**
- Added Commit Standards to docs/README guides section
- Added Design System guide to main README Documentation section
- Updated CHANGELOG GitHub URLs to schmoli/ios-template
- Added content to docs/patterns section with TODO marker
- Verified all doc cross-references are valid

**Build & Project Structure**
- Added `*.backup` pattern to .gitignore
- Removed orphaned `project.pbxproj.backup` file
- Fixed Xcode build conflict by using Swift placeholder files instead of README.md
- Added example component `WelcomeHeader.swift` to Features/Welcome/Components

**Empty Directories**
- Added Swift placeholder files with documentation as comments:
  - `Core/Networking/Networking.swift`
  - `Core/Persistence/Persistence.swift`
  - `Shared/Utilities/Utilities.swift`
- Added `docs/patterns/README.md` for code patterns (not in Xcode project)
- Each placeholder has TODO guidance for future implementation
- All directories maintain Xcode build compatibility

## [0.1.0] - 2026-01-04

### Added

**Core Infrastructure**
- Feature-based architecture (Core/, Features/, Shared/)
- Swift 6 strict concurrency mode (complete checking)
- AppLogger factory with type-safe LogCategory enum
- WelcomeView example feature with gradient background

**Design System**
- DesignConstants with 7 token categories (Spacing, CornerRadius, Animation, Typography, Shadow, IconSize, Opacity, BorderWidth)
- ViewExtensions: conditional modifiers, layout helpers, card style, debug tools
- ColorExtensions: hex init/conversion, brightness adjust, semantic colors

**Build Automation**
- `scripts/bootstrap.sh` - Development environment setup
- `scripts/build.sh` - Automated simulator builds
- `scripts/test.sh` - Test runner
- `scripts/install.sh` - Install and launch on simulator
- `scripts/setup.sh` - Template customization script

**Documentation**
- Architecture guide (feature modules, Swift 6 patterns, DI)
- Logging guide (AppLogger usage, categories, best practices)
- Design system guide (tokens and extension usage)
- Customization guide (template adaptation)
- Testing guide (Swift Testing framework setup)
- Commit standards (conventional commits, semantic versioning)
- Quick Start README with template philosophy

**Testing Infrastructure**
- Swift Testing test files (AppLoggerTests, WelcomeViewTests, ViewTestHelpers)
- Test target structure (requires manual Xcode configuration)

### Known Issues

- Test target requires manual Xcode configuration before tests can run
- See `docs/guides/testing.md` for setup instructions

### Notes

- Initial production-ready template release
- Pre-1.0 version: API may change in minor releases
- Marketing version synced with git tag (v0.1.0)

[Unreleased]: https://github.com/schmoli/ios-template/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/schmoli/ios-template/compare/v0.1.2...v0.2.0
[0.1.2]: https://github.com/schmoli/ios-template/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/schmoli/ios-template/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/schmoli/ios-template/releases/tag/v0.1.0
