import Testing
@testable import MyApp

struct AppLifecycleTests {

    @Test("Initial state is active")
    func initialState() async {
        let lifecycle = MockAppLifecycle()
        let state = await lifecycle.currentState
        #expect(state == .active)
    }

    @Test("Foreground handler is called")
    func foregroundHandler() async {
        await confirmation("Handler called") { confirm in
            let lifecycle = MockAppLifecycle()

            await lifecycle.onForeground {
                confirm()
            }

            await lifecycle.simulateForeground()
        }
    }

    @Test("Background handler is called")
    func backgroundHandler() async {
        await confirmation("Handler called") { confirm in
            let lifecycle = MockAppLifecycle()

            await lifecycle.onBackground {
                confirm()
            }

            await lifecycle.simulateBackground()
        }
    }

    @Test("Inactive handler is called")
    func inactiveHandler() async {
        await confirmation("Handler called") { confirm in
            let lifecycle = MockAppLifecycle()

            await lifecycle.onInactive {
                confirm()
            }

            await lifecycle.simulateInactive()
        }
    }

    @Test("Appear handler is called")
    func appearHandler() async {
        await confirmation("Handler called") { confirm in
            let lifecycle = MockAppLifecycle()

            await lifecycle.onAppear {
                confirm()
            }

            await lifecycle.simulateAppear()
        }
    }

    @Test("Multiple handlers are all called")
    func multipleHandlers() async {
        await confirmation("Handler called", expectedCount: 3) { confirm in
            let lifecycle = MockAppLifecycle()

            await lifecycle.onForeground { confirm() }
            await lifecycle.onForeground { confirm() }
            await lifecycle.onForeground { confirm() }

            await lifecycle.simulateForeground()
        }
    }

    @Test("State changes to background")
    func stateChangeBackground() async {
        let lifecycle = MockAppLifecycle()
        await lifecycle.simulateBackground()

        let state = await lifecycle.currentState
        #expect(state == .background)
    }
}
