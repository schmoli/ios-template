import Foundation

/// Categorizes log messages for filtering and organization.
///
/// Use these categories to organize logs by functional area:
/// - `.startup`: App lifecycle and initialization
/// - `.networking`: API calls, network requests
/// - `.ui`: User interface events and interactions
/// - `.data`: Data persistence and processing
/// - `.auth`: Authentication and authorization
/// - `.general`: Uncategorized logs
enum LogCategory: String, Sendable {
    case startup
    case networking
    case ui
    case data
    case auth
    case general
}
