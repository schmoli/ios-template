import SwiftUI
import Testing

/// Helper utilities for testing SwiftUI views.
enum ViewTestHelpers {

    /// Creates a test host for SwiftUI views.
    ///
    /// Useful for testing views that need a window or environment.
    static func createTestHost<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .frame(width: 375, height: 812) // iPhone size
    }
}
