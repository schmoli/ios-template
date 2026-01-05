import Testing
@testable import MyApp

struct SecureStorageTests {

    @Test("Save and load string value")
    func saveAndLoadString() async throws {
        let storage = MockSecureStorage()
        let key = "testString"
        let value = "Hello, Keychain!"

        try await storage.save(value, for: key)
        let loaded: String? = try await storage.load(for: key)

        #expect(loaded == value)
    }

    @Test("Save and load codable struct")
    func saveAndLoadCodable() async throws {
        struct Credentials: Codable, Equatable {
            let username: String
            let token: String
        }

        let storage = MockSecureStorage()
        let key = "credentials"
        let value = Credentials(username: "user@example.com", token: "secret-token")

        try await storage.save(value, for: key)
        let loaded: Credentials? = try await storage.load(for: key)

        #expect(loaded == value)
    }

    @Test("Load nonexistent key returns nil")
    func loadNonexistent() async throws {
        let storage = MockSecureStorage()
        let loaded: String? = try await storage.load(for: "doesNotExist")

        #expect(loaded == nil)
    }

    @Test("Delete removes value")
    func deleteValue() async throws {
        let storage = MockSecureStorage()
        let key = "toDelete"
        let value = "temporary"

        try await storage.save(value, for: key)
        #expect(storage.exists(for: key))

        try await storage.delete(for: key)
        #expect(!storage.exists(for: key))

        let loaded: String? = try await storage.load(for: key)
        #expect(loaded == nil)
    }

    @Test("Exists returns correct status")
    func existsCheck() async throws {
        let storage = MockSecureStorage()
        let key = "existsTest"

        #expect(!storage.exists(for: key))

        try await storage.save("value", for: key)
        #expect(storage.exists(for: key))

        try await storage.delete(for: key)
        #expect(!storage.exists(for: key))
    }

    @Test("Save overwrites existing value")
    func overwriteValue() async throws {
        let storage = MockSecureStorage()
        let key = "overwrite"

        try await storage.save("first", for: key)
        try await storage.save("second", for: key)

        let loaded: String? = try await storage.load(for: key)
        #expect(loaded == "second")
    }
}
