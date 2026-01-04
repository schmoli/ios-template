import SwiftUI

/// Example component for the Welcome feature.
///
/// This demonstrates how to structure feature-specific components.
/// Replace or remove this as you build your actual welcome screen.
struct WelcomeHeader: View {
    let title: String

    var body: some View {
        VStack(spacing: DesignConstants.Spacing.small) {
            Image(systemName: "globe")
                .font(.system(size: DesignConstants.IconSize.extraLarge))
                .foregroundStyle(.tint)

            Text(title)
                .font(DesignConstants.Typography.title1)
        }
        .padding(DesignConstants.Spacing.medium)
    }
}

#Preview {
    WelcomeHeader(title: "Hello, iOS 26!")
}
