import SwiftUI

/// Global design constants for the app.
///
/// Centralizes spacing, sizing, and other design tokens
/// to ensure consistency across the UI.
enum DesignConstants {
    /// Standard spacing values
    enum Spacing {
        static let extraSmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
        static let huge: CGFloat = 48
    }

    /// Corner radius values
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
        static let circle: CGFloat = 9999  // For circular shapes
    }

    /// Animation durations
    enum Animation {
        static let quick: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
        static let verySlow: Double = 0.8
    }

    /// Typography styles
    enum Typography {
        static let largeTitle: Font = .largeTitle
        static let title1: Font = .title
        static let title2: Font = .title2
        static let title3: Font = .title3
        static let headline: Font = .headline
        static let body: Font = .body
        static let callout: Font = .callout
        static let subheadline: Font = .subheadline
        static let footnote: Font = .footnote
        static let caption: Font = .caption
        static let caption2: Font = .caption2

        // Custom weights
        static let bodyBold: Font = .body.bold()
        static let headlineLight: Font = .headline.weight(.light)
    }

    /// Shadow configurations
    enum Shadow {
        static let small: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            color: Color.black.opacity(0.1),
            radius: 2,
            x: 0,
            y: 1
        )

        static let medium: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            color: Color.black.opacity(0.15),
            radius: 4,
            x: 0,
            y: 2
        )

        static let large: (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) = (
            color: Color.black.opacity(0.2),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    /// Standard icon sizes
    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 24
        static let large: CGFloat = 32
        static let extraLarge: CGFloat = 48
    }

    /// Common opacity values
    enum Opacity {
        static let disabled: Double = 0.5
        static let subtle: Double = 0.7
        static let overlay: Double = 0.3
    }

    /// Standard border widths
    enum BorderWidth {
        static let thin: CGFloat = 1
        static let medium: CGFloat = 2
        static let thick: CGFloat = 3
    }
}
