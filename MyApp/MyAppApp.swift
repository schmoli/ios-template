import SwiftUI
import os.log

@main
struct MyAppApp: App {
    private let logger = Logger(subsystem: "com.example.MyApp", category: "startup")

    init() {
        logger.log("🚀 MyApp starting up on iOS 26!")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
