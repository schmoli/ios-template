import SwiftUI

// MARK: - Hex Initializer

extension Color {
    /// Creates a Color from a hex string
    ///
    /// Supports formats: "#RRGGBB", "#AARRGGBB", "RRGGBB", "AARRGGBB"
    ///
    /// Example:
    /// ```swift
    /// Color(hex: "#FF5733")
    /// Color(hex: "FF5733")
    /// Color(hex: "#80FF5733")  // With alpha
    /// ```
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let length = hexSanitized.count
        let r, g, b, a: Double

        if length == 6 {
            // RGB (no alpha)
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            // ARGB
            a = Double((rgb & 0xFF000000) >> 24) / 255.0
            r = Double((rgb & 0x00FF0000) >> 16) / 255.0
            g = Double((rgb & 0x0000FF00) >> 8) / 255.0
            b = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, opacity: a)
    }

    /// Returns hex string representation of color
    ///
    /// Example:
    /// ```swift
    /// let color = Color.red
    /// let hex = color.toHex()  // "#FF0000" (approximately)
    /// ```
    func toHex(includeAlpha: Bool = false) -> String? {
        #if canImport(UIKit)
        guard let components = UIColor(self).cgColor.components else {
            return nil
        }

        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)

        if includeAlpha, components.count >= 4 {
            let a = Int(components[3] * 255.0)
            return String(format: "#%02X%02X%02X%02X", a, r, g, b)
        } else {
            return String(format: "#%02X%02X%02X", r, g, b)
        }
        #else
        return nil
        #endif
    }
}

// MARK: - Brightness Adjustments

extension Color {
    /// Returns a lighter version of the color
    ///
    /// Example:
    /// ```swift
    /// Color.blue.lighter(by: 0.2)  // 20% lighter
    /// ```
    func lighter(by percentage: Double = 0.2) -> Color {
        adjust(by: abs(percentage))
    }

    /// Returns a darker version of the color
    ///
    /// Example:
    /// ```swift
    /// Color.blue.darker(by: 0.2)  // 20% darker
    /// ```
    func darker(by percentage: Double = 0.2) -> Color {
        adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: Double) -> Color {
        #if canImport(UIKit)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return Color(
            red: min(red + percentage, 1.0),
            green: min(green + percentage, 1.0),
            blue: min(blue + percentage, 1.0),
            opacity: Double(alpha)
        )
        #else
        return self
        #endif
    }
}

// MARK: - Semantic Colors

extension Color {
    /// Adaptive text color (black on light backgrounds, white on dark)
    ///
    /// Example:
    /// ```swift
    /// Text("Adaptive text")
    ///     .foregroundStyle(Color.adaptiveText)
    /// ```
    static var adaptiveText: Color {
        Color(UIColor.label)
    }

    /// Adaptive secondary text color
    static var adaptiveSecondaryText: Color {
        Color(UIColor.secondaryLabel)
    }

    /// Adaptive background color
    static var adaptiveBackground: Color {
        Color(UIColor.systemBackground)
    }

    /// Adaptive grouped background color (for grouped lists)
    static var adaptiveGroupedBackground: Color {
        Color(UIColor.systemGroupedBackground)
    }
}

// MARK: - Random Color (Debug)

extension Color {
    /// Generates a random color (useful for debugging layouts)
    ///
    /// Example:
    /// ```swift
    /// Rectangle()
    ///     .fill(Color.random)
    ///     .debugBorder()
    /// ```
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
