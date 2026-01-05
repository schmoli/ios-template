import Foundation
import SwiftData

/// SwiftData-backed implementation of PersistenceProtocol
actor SwiftDataPersistence: PersistenceProtocol {
    static let shared = SwiftDataPersistence()

    let modelContainer: ModelContainer

    private init() {
        // Create schema with no models initially
        // Apps will configure their own schema when needed
        let schema = Schema([])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // Fallback to in-memory if file-based fails
            let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            do {
                self.modelContainer = try ModelContainer(for: schema, configurations: [memoryConfig])
            } catch {
                fatalError("Failed to create ModelContainer: \(error)")
            }
        }
    }

    /// Create instance with custom schema (for apps with models)
    init(schema: Schema, isInMemory: Bool = false) throws {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: isInMemory)
        self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
    }

    @MainActor
    func save() async throws {
        let context = modelContainer.mainContext
        do {
            try context.save()
        } catch {
            throw PersistenceError.saveFailed(error)
        }
    }
}
