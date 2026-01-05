import Foundation

/// Protocol for biometric authentication (Face ID / Touch ID)
protocol BiometricAuthProtocol: Sendable {
    /// Type of biometric authentication available
    var biometricType: BiometricType { get async }

    /// Whether biometric authentication is available and enrolled
    var isAvailable: Bool { get async }

    /// Authenticate user with biometrics
    /// - Parameter reason: User-facing reason for authentication request
    /// - Returns: true if authentication succeeded
    /// - Throws: BiometricAuthError if authentication fails or is unavailable
    func authenticate(reason: String) async throws -> Bool
}
