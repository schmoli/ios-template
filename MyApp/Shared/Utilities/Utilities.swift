// Utilities
//
// Intent: Provide reusable helper functions and utilities used across features.
//
// This directory is for general-purpose code that doesn't belong in a specific feature
// or core system. Keep utilities focused, testable, and independent of UI.
//
// Common utilities you might add here:
// - String formatting and manipulation
// - Date/time helpers
// - Validation functions
// - File management helpers
// - Mathematical or algorithmic helpers
// - Type conversions and transformations
//
// Design decisions you'll make:
// - Whether to use static methods, free functions, or extensions
// - How to handle Swift 6 concurrency (Sendable conformance, @MainActor)
// - Naming conventions for discoverability
// - Whether utilities should be pure functions or stateful
//
// Guidelines:
// - Prefer extensions over utility classes when it makes sense
// - Keep utilities pure (no side effects) when possible
// - Consider Swift 6 concurrency requirements (Sendable, isolation)
// - Put UI-specific utilities in Shared/Extensions instead
//
// See Shared/Extensions/ for View and Color extensions.

import Foundation

// This file exists to maintain directory structure in Xcode.
// Delete this file when you add your first utility implementation.
