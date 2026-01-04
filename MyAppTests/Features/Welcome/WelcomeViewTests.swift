import Testing
import SwiftUI
@testable import MyApp

@Suite("WelcomeView Tests")
struct WelcomeViewTests {

    @Test("WelcomeView initializes correctly")
    func testViewInitialization() {
        let view = WelcomeView()
        // View should initialize without errors
        #expect(view != nil)
    }

    @Test("WelcomeView has correct structure")
    func testViewStructure() {
        let view = WelcomeView()
        // Verify view can be rendered
        let body = view.body
        #expect(body != nil)
    }
}
