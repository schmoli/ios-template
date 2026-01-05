import Foundation

/// Mock implementation of SecureStorageProtocol for testing
/// Uses in-memory dictionary, no actual keychain access
final class MockSecureStorage: SecureStorageProtocol, @unchecked Sendable {
    private var storage: [String: Data] = [:]
    private let lock = NSLock()

    func save<T: Codable & Sendable>(_ value: T, for key: String) async throws {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(value)
            lock.withLock {
                storage[key] = data
            }
        } catch {
            throw SecureStorageError.encodingFailed(error.localizedDescription)
        }
    }

    func load<T: Codable & Sendable>(for key: String) async throws -> T? {
        let data = lock.withLock { storage[key] }
        guard let data else { return nil }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw SecureStorageError.decodingFailed(error.localizedDescription)
        }
    }

    func delete(for key: String) async throws {
        lock.withLock {
            storage.removeValue(forKey: key)
        }
    }

    func exists(for key: String) -> Bool {
        lock.withLock {
            storage[key] != nil
        }
    }

    /// Test helper: clear all stored data
    func clear() {
        lock.withLock {
            storage.removeAll()
        }
    }
}
