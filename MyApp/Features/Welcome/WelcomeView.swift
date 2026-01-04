import SwiftUI

/// Main welcome screen shown on app launch.
struct WelcomeView: View {
    var body: some View {
        ZStack {
            GradientBackground()
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, iOS 26!")
                    .font(.title)
                    .padding()
            }
            .padding()
        }
    }
}

#Preview {
    WelcomeView()
        .preferredColorScheme(.dark)
}
