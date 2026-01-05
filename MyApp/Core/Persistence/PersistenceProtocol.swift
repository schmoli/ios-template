import Foundation
import SwiftData

/// Protocol for data persistence operations
protocol PersistenceProtocol: Sendable {
    /// The underlying ModelContainer for SwiftData operations
    var modelContainer: ModelContainer { get }

    /// Save all pending changes
    /// - Throws: PersistenceError if save fails
    func save() async throws
}
