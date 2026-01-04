import SwiftUI

/// Reusable gradient background component
/// Uses theme color with gradient extending beyond screen bounds for subtle effect
struct GradientBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    enum GradientStops {
        /// Top gradient stop (extends slightly above screen for subtle color at top)
        static let top: Double = -0.15

        /// Bottom gradient stop (extends well below screen for darker color at bottom)
        static let bottom: Double = 1.75
    }
    
    var body: some View {
        // Gradient extends beyond screen (both top and bottom)
        LinearGradient(
            stops: [
                .init(
                    color: colorScheme == .dark ? .black : .white,
                    location: GradientStops.top
                ),
                .init(
                    color: .accentColor,
                    location: GradientStops.bottom
                )
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        GradientBackground()

        VStack {
            Text("Gradient background")
        }
    }
}
