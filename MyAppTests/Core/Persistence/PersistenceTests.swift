import Testing
import SwiftData
import Foundation
@testable import MyApp

// Test model
@Model
class TestItem {
    var name: String
    var timestamp: Date

    init(name: String, timestamp: Date = Date()) {
        self.name = name
        self.timestamp = timestamp
    }
}

struct PersistenceTests {

    @Test("Create in-memory persistence")
    func createPersistence() async throws {
        let schema = Schema([TestItem.self])
        let persistence = try SwiftDataPersistence(schema: schema, isInMemory: true)

        let container = await persistence.modelContainer
        #expect(container.schema.entities.count > 0)
    }

    @Test("Save and fetch item")
    @MainActor
    func saveAndFetch() async throws {
        let schema = Schema([TestItem.self])
        let persistence = try SwiftDataPersistence(schema: schema, isInMemory: true)

        let container = await persistence.modelContainer
        let context = container.mainContext

        // Insert item
        let item = TestItem(name: "Test Item")
        context.insert(item)

        // Save
        try await persistence.save()

        // Fetch
        let descriptor = FetchDescriptor<TestItem>()
        let items = try context.fetch(descriptor)

        #expect(items.count == 1)
        #expect(items.first?.name == "Test Item")
    }

    @Test("Delete item")
    @MainActor
    func deleteItem() async throws {
        let schema = Schema([TestItem.self])
        let persistence = try SwiftDataPersistence(schema: schema, isInMemory: true)

        let container = await persistence.modelContainer
        let context = container.mainContext

        // Insert and save
        let item = TestItem(name: "To Delete")
        context.insert(item)
        try await persistence.save()

        // Delete and save
        context.delete(item)
        try await persistence.save()

        // Verify deleted
        let descriptor = FetchDescriptor<TestItem>()
        let items = try context.fetch(descriptor)
        #expect(items.isEmpty)
    }

    @Test("Multiple items")
    @MainActor
    func multipleItems() async throws {
        let schema = Schema([TestItem.self])
        let persistence = try SwiftDataPersistence(schema: schema, isInMemory: true)

        let container = await persistence.modelContainer
        let context = container.mainContext

        // Insert multiple
        context.insert(TestItem(name: "Item 1"))
        context.insert(TestItem(name: "Item 2"))
        context.insert(TestItem(name: "Item 3"))

        try await persistence.save()

        // Fetch all
        let descriptor = FetchDescriptor<TestItem>()
        let items = try context.fetch(descriptor)

        #expect(items.count == 3)
    }
}
