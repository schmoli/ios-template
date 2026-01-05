import Testing
import Foundation
@testable import MyApp

@Suite("CircuitBreaker Tests")
struct CircuitBreakerTests {

    @Test("Starts in closed state")
    func testInitialState() async {
        let breaker = CircuitBreaker()
        let state = await breaker.state
        #expect(state == .closed)
    }

    @Test("Opens after failure threshold")
    func testOpensAfterFailures() async throws {
        let breaker = CircuitBreaker()
        let endpoint = "api.example.com"

        // Record 5 failures
        for _ in 1...5 {
            await breaker.recordFailure(for: endpoint)
        }

        let state = await breaker.state
        #expect(state == .open)
    }

    @Test("Allows requests when closed")
    func testAllowsRequestsWhenClosed() async throws {
        let breaker = CircuitBreaker()
        let endpoint = "api.example.com"

        let allowed = try await breaker.shouldAllowRequest(for: endpoint)
        #expect(allowed == true)
    }

    @Test("Blocks requests when open")
    func testBlocksRequestsWhenOpen() async throws {
        let breaker = CircuitBreaker()
        let endpoint = "api.example.com"

        // Trip the circuit
        for _ in 1...5 {
            await breaker.recordFailure(for: endpoint)
        }

        await #expect(throws: APIError.self) {
            try await breaker.shouldAllowRequest(for: endpoint)
        }
    }

    @Test("Resets on successful request")
    func testResetsOnSuccess() async {
        let breaker = CircuitBreaker()
        let endpoint = "api.example.com"

        // Record some failures
        await breaker.recordFailure(for: endpoint)
        await breaker.recordFailure(for: endpoint)

        // Successful request resets counter
        await breaker.recordSuccess(for: endpoint)

        let failures = await breaker.consecutiveFailures(for: endpoint)
        #expect(failures == 0)
    }

    @Test("Independent circuits per endpoint")
    func testIndependentCircuits() async {
        let breaker = CircuitBreaker()
        let endpoint1 = "api1.example.com"
        let endpoint2 = "api2.example.com"

        // Trip circuit for endpoint1
        for _ in 1...5 {
            await breaker.recordFailure(for: endpoint1)
        }

        // endpoint2 should still be closed
        let allowed = try? await breaker.shouldAllowRequest(for: endpoint2)
        #expect(allowed == true)
    }
}
