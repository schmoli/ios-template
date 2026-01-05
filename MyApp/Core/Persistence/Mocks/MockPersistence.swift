import Foundation
import SwiftData

/// Mock implementation of PersistenceProtocol for testing
/// Uses in-memory SwiftData container
actor MockPersistence: PersistenceProtocol {
    let modelContainer: ModelContainer

    init() {
        let schema = Schema([])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        do {
            self.modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create mock ModelContainer: \(error)")
        }
    }

    /// Create mock with custom schema
    init(schema: Schema) throws {
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
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

    /// Test helper: clear all data
    @MainActor
    func reset() throws {
        let context = modelContainer.mainContext
        // Delete is handled per-model by tests since schema varies
        try context.save()
    }
}

// Placeholder model for schema
@Model
private class SwiftDataModel {
    init() {}
}
