import Testing
import SwiftUI
@testable import MyApp

@Suite("WelcomeView Tests")
struct WelcomeViewTests {

    @Test("WelcomeView initializes without crashing")
    func testViewInitialization() {
        // Proves view constructs successfully
        let view = WelcomeView()
        #expect(view != nil)
    }

    // Visual verification done via #Preview in WelcomeView.swift
    // For UI correctness, launch app and inspect manually per "Iterate UI by Preview" principle
}
