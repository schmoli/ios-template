import Foundation
import LocalAuthentication

/// LocalAuthentication-backed implementation of BiometricAuthProtocol
actor LocalBiometricAuth: BiometricAuthProtocol {
    static let shared = LocalBiometricAuth()

    private init() {}

    var biometricType: BiometricType {
        get async {
            let context = LAContext()
            var error: NSError?

            guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
                return .none
            }

            switch context.biometryType {
            case .faceID:
                return .faceID
            case .touchID:
                return .touchID
            case .none, .opticID:
                return .none
            @unknown default:
                return .none
            }
        }
    }

    var isAvailable: Bool {
        get async {
            let context = LAContext()
            var error: NSError?
            return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        }
    }

    func authenticate(reason: String) async throws -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error {
                throw mapError(error)
            }
            throw BiometricAuthError.notAvailable
        }

        do {
            return try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
        } catch let error as LAError {
            throw mapLAError(error)
        } catch {
            throw BiometricAuthError.systemError(error.localizedDescription)
        }
    }

    private func mapError(_ error: NSError) -> BiometricAuthError {
        guard let laError = error as? LAError else {
            return .systemError(error.localizedDescription)
        }
        return mapLAError(laError)
    }

    private func mapLAError(_ error: LAError) -> BiometricAuthError {
        switch error.code {
        case .biometryNotAvailable:
            return .notAvailable
        case .biometryNotEnrolled:
            return .notEnrolled
        case .userCancel, .systemCancel, .appCancel:
            return .userCanceled
        case .authenticationFailed:
            return .authenticationFailed
        case .biometryLockout:
            return .lockout
        default:
            return .systemError(error.localizedDescription)
        }
    }
}
