import Foundation

/// Errors that can occur during biometric authentication
enum BiometricAuthError: Error, Sendable, Equatable {
    case notAvailable
    case notEnrolled
    case userCanceled
    case authenticationFailed
    case lockout
    case systemError(String)

    static func == (lhs: BiometricAuthError, rhs: BiometricAuthError) -> Bool {
        switch (lhs, rhs) {
        case (.notAvailable, .notAvailable),
             (.notEnrolled, .notEnrolled),
             (.userCanceled, .userCanceled),
             (.authenticationFailed, .authenticationFailed),
             (.lockout, .lockout):
            return true
        case (.systemError(let a), .systemError(let b)):
            return a == b
        default:
            return false
        }
    }
}

extension BiometricAuthError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "Biometric authentication is not available on this device"
        case .notEnrolled:
            return "No biometric data is enrolled on this device"
        case .userCanceled:
            return "User canceled the authentication request"
        case .authenticationFailed:
            return "Biometric authentication failed"
        case .lockout:
            return "Biometric authentication is locked out due to too many failed attempts"
        case .systemError(let message):
            return "System error: \(message)"
        }
    }
}
