import Testing
import Foundation
@testable import MyApp

@Suite("RetryPolicy Tests")
struct RetryPolicyTests {

    @Test("Max attempts is 3")
    func testMaxAttempts() {
        let policy = RetryPolicy()
        #expect(policy.maxAttempts == 3)
    }

    @Test("Exponential backoff: 1s, 2s, 4s")
    func testExponentialBackoff() {
        let policy = RetryPolicy()
        #expect(policy.delay(for: 1) == 1.0)
        #expect(policy.delay(for: 2) == 2.0)
        #expect(policy.delay(for: 3) == 4.0)
    }

    @Test("Should retry network failures", arguments: [
        URLError.Code.networkConnectionLost,
        URLError.Code.timedOut,
        URLError.Code.cannotConnectToHost,
        URLError.Code.notConnectedToInternet
    ])
    func testShouldRetryNetworkErrors(errorCode: URLError.Code) {
        let policy = RetryPolicy()
        let error = URLError(errorCode)
        #expect(policy.shouldRetry(error: error) == true)
    }

    @Test("Should not retry on max attempts")
    func testMaxAttemptsReached() {
        let policy = RetryPolicy()
        let error = URLError(.networkConnectionLost)
        #expect(policy.shouldRetry(error: error, attempt: 3) == false)
        #expect(policy.shouldRetry(error: error, attempt: 4) == false)
    }

    @Test("Should not retry non-network errors")
    func testNonNetworkErrors() {
        let policy = RetryPolicy()
        let error = URLError(.cancelled)
        #expect(policy.shouldRetry(error: error) == false)
    }
}
