import Foundation
import Security

/// Keychain-backed implementation of SecureStorageProtocol
actor KeychainSecureStorage: SecureStorageProtocol {
    static let shared = KeychainSecureStorage()

    private let serviceName: String

    private init() {
        self.serviceName = Bundle.main.bundleIdentifier ?? "com.example.MyApp"
    }

    func save<T: Codable & Sendable>(_ value: T, for key: String) async throws {
        let encoder = JSONEncoder()
        let data: Data
        do {
            data = try encoder.encode(value)
        } catch {
            throw SecureStorageError.encodingFailed(error.localizedDescription)
        }

        // Build query for this key
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        // Try to save
        var status = SecItemAdd(query as CFDictionary, nil)

        // If item exists, update instead
        if status == errSecDuplicateItem {
            let updateQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: serviceName,
                kSecAttrAccount as String: key
            ]
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: data
            ]
            status = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
        }

        guard status == errSecSuccess else {
            throw SecureStorageError.saveFailed(status)
        }
    }

    func load<T: Codable & Sendable>(for key: String) async throws -> T? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else {
            throw SecureStorageError.loadFailed(status)
        }

        guard let data = result as? Data else { return nil }

        let decoder = JSONDecoder()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw SecureStorageError.decodingFailed(error.localizedDescription)
        }
    }

    func delete(for key: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw SecureStorageError.deleteFailed(status)
        }
    }

    nonisolated func exists(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
}
