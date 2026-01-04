import Foundation

/// Global design constants for the app.
///
/// Centralizes spacing, sizing, and other design tokens
/// to ensure consistency across the UI.
enum DesignConstants {
    /// Standard spacing values
    enum Spacing {
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    /// Corner radius values
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
    }

    /// Animation durations
    enum Animation {
        static let quick: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
    }
}
