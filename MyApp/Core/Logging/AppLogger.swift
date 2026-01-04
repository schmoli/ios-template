import os.log

/// Centralized logging system for the app.
///
/// Provides type-safe logger creation with consistent subsystem naming.
/// All loggers use the app's bundle identifier as the subsystem.
///
/// Usage:
/// ```swift
/// private let logger = AppLogger.logger(for: .networking)
/// logger.info("Request completed successfully")
/// ```
enum AppLogger {
    /// Centralized subsystem identifier.
    ///
    /// Update this when customizing the template for a new project.
    static let subsystem = "com.example.MyApp"

    /// Creates a logger for the specified category.
    ///
    /// - Parameter category: The functional category for this logger
    /// - Returns: Configured Logger instance
    static func logger(for category: LogCategory) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }
}
