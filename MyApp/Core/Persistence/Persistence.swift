// Persistence
//
// Intent: Manage local data storage and persistence across app launches.
//
// This directory is for code that stores, retrieves, and manages data locally on the device.
// Keep persistence logic separate from UI and business logic.
//
// Common components you might add here:
// - Data models and schemas
// - Storage interfaces and repositories
// - Migration logic for schema changes
// - Cache management
//
// Design decisions you'll make:
// - Which persistence technology to use:
//   - SwiftData (modern, Swift-first, recommended for new projects)
//   - CoreData (mature, feature-rich, well-documented)
//   - UserDefaults (simple key-value for settings)
//   - Keychain (secure storage for credentials)
//   - FileManager (files and documents)
//   - SQLite directly (maximum control)
// - Data model structure and relationships
// - Migration strategy for schema changes
// - Caching strategy and invalidation
// - How to inject storage into features (see architecture guide)
//
// See docs/guides/architecture.md for dependency injection patterns.

import Foundation

// This file exists to maintain directory structure in Xcode.
// Delete this file when you add your first persistence implementation.
