import Foundation

/// Protocol for securely storing sensitive data using platform keychain
protocol SecureStorageProtocol: Sendable {
    /// Save a Codable value to secure storage
    /// - Parameters:
    ///   - value: The value to store
    ///   - key: Unique identifier for this value
    /// - Throws: SecureStorageError if save fails
    func save<T: Codable & Sendable>(_ value: T, for key: String) async throws

    /// Load a Codable value from secure storage
    /// - Parameter key: Unique identifier for the value
    /// - Returns: The decoded value, or nil if not found
    /// - Throws: SecureStorageError if load or decoding fails
    func load<T: Codable & Sendable>(for key: String) async throws -> T?

    /// Delete a value from secure storage
    /// - Parameter key: Unique identifier for the value to delete
    /// - Throws: SecureStorageError if deletion fails
    func delete(for key: String) async throws

    /// Check if a value exists in secure storage
    /// - Parameter key: Unique identifier for the value
    /// - Returns: true if the key exists, false otherwise
    func exists(for key: String) -> Bool
}
