# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/yourusername/ios-template/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/yourusername/ios-template/releases/tag/v0.1.0
