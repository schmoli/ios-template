import SwiftUI

// MARK: - Conditional Modifiers

extension View {
    /// Conditionally applies a modifier based on a boolean condition
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .if(isHighlighted) { view in
    ///         view.foregroundStyle(.red)
    ///     }
    /// ```
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Conditionally applies one of two modifiers
    ///
    /// Example:
    /// ```swift
    /// Text("Status")
    ///     .if(isActive, then: { $0.foregroundStyle(.green) },
    ///                   else: { $0.foregroundStyle(.gray) })
    /// ```
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}

// MARK: - Layout Helpers

extension View {
    /// Centers view in parent with optional padding
    ///
    /// Example:
    /// ```swift
    /// Text("Centered")
    ///     .centered(padding: 20)
    /// ```
    func centered(padding: CGFloat = 0) -> some View {
        HStack {
            Spacer(minLength: padding)
            self
            Spacer(minLength: padding)
        }
    }

    /// Applies corner radius to specific corners
    ///
    /// Example:
    /// ```swift
    /// Rectangle()
    ///     .cornerRadius(12, corners: [.topLeft, .topRight])
    /// ```
    func cornerRadius(
        _ radius: CGFloat,
        corners: UIRectCorner
    ) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Supporting Types

private struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Debug Helpers

extension View {
    /// Prints view lifecycle events (debug builds only)
    ///
    /// Example:
    /// ```swift
    /// Text("Hello")
    ///     .debugPrint("Text view appeared")
    /// ```
    func debugPrint(_ message: String) -> some View {
        #if DEBUG
        print("🔍 \(message)")
        #endif
        return self
    }

    /// Adds colored border for debugging layout (debug builds only)
    ///
    /// Example:
    /// ```swift
    /// VStack {
    ///     Text("Debug layout")
    /// }
    /// .debugBorder()
    /// ```
    func debugBorder(
        _ color: Color = .red,
        width: CGFloat = 1
    ) -> some View {
        #if DEBUG
        return self.border(color, width: width)
        #else
        return self
        #endif
    }
}

// MARK: - Styling Shortcuts

extension View {
    /// Applies consistent card styling
    ///
    /// Example:
    /// ```swift
    /// VStack {
    ///     Text("Card content")
    /// }
    /// .cardStyle()
    /// ```
    func cardStyle(
        backgroundColor: Color = Color(.systemBackground),
        cornerRadius: CGFloat = DesignConstants.CornerRadius.medium,
        shadowRadius: CGFloat = 4
    ) -> some View {
        self
            .padding()
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: .black.opacity(0.1), radius: shadowRadius)
    }
}
