import SwiftUI

struct ContentView: View {
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
    ContentView()
        .preferredColorScheme(.dark)
}
