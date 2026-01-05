import Foundation

/// Errors that can occur during persistence operations
enum PersistenceError: Error, Sendable {
    case saveFailed(Error)
    case deleteFailed(Error)
    case fetchFailed(Error)
    case containerCreationFailed(Error)
}

extension PersistenceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .saveFailed(let error):
            return "Failed to save: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete: \(error.localizedDescription)"
        case .fetchFailed(let error):
            return "Failed to fetch: \(error.localizedDescription)"
        case .containerCreationFailed(let error):
            return "Failed to create persistence container: \(error.localizedDescription)"
        }
    }
}
