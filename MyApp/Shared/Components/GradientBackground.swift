import SwiftUI

/// Reusable gradient background component.
///
/// Provides a consistent gradient effect across the app.
/// Uses colors from the app's design system.
struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.blue, .purple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }
}

#Preview {
    GradientBackground()
}
