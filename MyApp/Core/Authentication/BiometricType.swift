import Foundation

/// Type of biometric authentication available on device
enum BiometricType: Sendable, Equatable {
    case faceID
    case touchID
    case none
}
