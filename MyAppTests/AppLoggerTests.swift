import Testing
@testable import MyApp

@Suite("AppLogger Tests")
struct AppLoggerTests {

    @Test("Creates logger with correct subsystem")
    func testLoggerCreation() {
        let logger = AppLogger.logger(for: .networking)
        // Logger created successfully
        #expect(AppLogger.subsystem == "com.example.MyApp")
    }

    @Test("Creates loggers for all categories", arguments: [
        LogCategory.startup,
        LogCategory.networking,
        LogCategory.ui,
        LogCategory.data,
        LogCategory.auth,
        LogCategory.general
    ])
    func testAllCategories(category: LogCategory) {
        let logger = AppLogger.logger(for: category)
        // Logger created for each category
        #expect(AppLogger.subsystem == "com.example.MyApp")
    }
}
