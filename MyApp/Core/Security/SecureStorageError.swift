import Foundation

/// Errors that can occur during secure storage operations
enum SecureStorageError: Error, Sendable, Equatable {
    case encodingFailed(String)
    case decodingFailed(String)
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case notFound

    static func == (lhs: SecureStorageError, rhs: SecureStorageError) -> Bool {
        switch (lhs, rhs) {
        case (.encodingFailed(let a), .encodingFailed(let b)): return a == b
        case (.decodingFailed(let a), .decodingFailed(let b)): return a == b
        case (.saveFailed(let a), .saveFailed(let b)): return a == b
        case (.loadFailed(let a), .loadFailed(let b)): return a == b
        case (.deleteFailed(let a), .deleteFailed(let b)): return a == b
        case (.notFound, .notFound): return true
        default: return false
        }
    }
}

extension SecureStorageError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let message):
            return "Failed to encode value: \(message)"
        case .decodingFailed(let message):
            return "Failed to decode value: \(message)"
        case .saveFailed(let status):
            return "Failed to save to keychain (status: \(status))"
        case .loadFailed(let status):
            return "Failed to load from keychain (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete from keychain (status: \(status))"
        case .notFound:
            return "Item not found in keychain"
        }
    }
}
