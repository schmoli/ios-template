import Foundation

/// Mock implementation of BiometricAuthProtocol for testing
actor MockBiometricAuth: BiometricAuthProtocol {
    var biometricType: BiometricType
    var isAvailable: Bool
    var shouldSucceed: Bool
    var errorToThrow: BiometricAuthError?

    init(
        biometricType: BiometricType = .faceID,
        isAvailable: Bool = true,
        shouldSucceed: Bool = true,
        errorToThrow: BiometricAuthError? = nil
    ) {
        self.biometricType = biometricType
        self.isAvailable = isAvailable
        self.shouldSucceed = shouldSucceed
        self.errorToThrow = errorToThrow
    }

    func authenticate(reason: String) async throws -> Bool {
        if let error = errorToThrow {
            throw error
        }
        return shouldSucceed
    }

    // Test helpers
    func configure(type: BiometricType, available: Bool, succeeds: Bool) {
        self.biometricType = type
        self.isAvailable = available
        self.shouldSucceed = succeeds
    }

    func setError(_ error: BiometricAuthError?) {
        self.errorToThrow = error
    }
}
