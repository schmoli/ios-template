// Persistence
//
// TODO: Add data persistence when your app needs local storage.
//
// ## What Goes Here
//
// - DataStore.swift - Main persistence interface
// - Models/ - SwiftData or CoreData models
// - Migrations/ - Schema migrations
// - PersistenceController.swift - Setup and configuration
//
// ## Recommended Approach
//
// Use **SwiftData** for new Swift 6 projects:
//
// ```swift
// // Models/User.swift
// import SwiftData
//
// @Model
// final class User {
//     var id: UUID
//     var name: String
//     var createdAt: Date
//
//     init(id: UUID = UUID(), name: String, createdAt: Date = Date()) {
//         self.id = id
//         self.name = name
//         self.createdAt = createdAt
//     }
// }
// ```
//
// ```swift
// // DataStore.swift
// import SwiftData
//
// @MainActor
// final class DataStore {
//     static let shared = DataStore()
//
//     private let container: ModelContainer
//
//     private init() {
//         do {
//             container = try ModelContainer(for: User.self)
//         } catch {
//             fatalError("Failed to create ModelContainer: \(error)")
//         }
//     }
//
//     var context: ModelContext {
//         container.mainContext
//     }
// }
// ```
//
// ## When to Add This
//
// Add persistence when you need to:
// - Store user data locally
// - Cache API responses
// - Maintain app state across launches
// - Support offline mode
//
// ## Alternatives
//
// - **UserDefaults** - Simple key-value storage (settings, flags)
// - **Keychain** - Secure storage (credentials, tokens)
// - **FileManager** - Files and documents
// - **SwiftData** - Recommended for Swift 6 (modern, Swift-first)
// - **CoreData** - Legacy option (mature, well-documented)
//
// ## See Also
//
// - Architecture Guide: `docs/guides/architecture.md`
// - SwiftData Documentation: https://developer.apple.com/documentation/swiftdata

import Foundation

// This file exists to maintain directory structure in Xcode.
// Delete this file when you add your first persistence implementation.
