import Testing
import Foundation
@testable import MyApp

@Suite("NetworkService Tests", .serialized)
struct NetworkServiceTests {

    /// Create test URLSession configured with MockURLProtocol
    func createMockSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    @Test("Successful request returns decoded response")
    func testSuccessfulRequest() async throws {
        // Setup mock response
        struct TestResponse: Codable {
            let message: String
        }

        let expectedData = try JSONEncoder().encode(TestResponse(message: "success"))
        let expectedResponse = HTTPURLResponse(
            url: URL(string: "https://api.example.com/test")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: ["Content-Type": "application/json"]
        )!

        MockURLProtocol.requestHandler = { _ in
            return (expectedResponse, expectedData)
        }

        // Execute request
        let service = NetworkService(session: createMockSession())
        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpMethod = "GET"

        let response: TestResponse = try await service.execute(request)
        #expect(response.message == "success")
    }

    @Test("Retries network failures up to 3 times")
    func testRetriesNetworkFailures() async throws {
        final class Counter: @unchecked Sendable {
            let lock = NSLock()
            var value = 0
            func increment() -> Int {
                lock.lock()
                defer { lock.unlock() }
                value += 1
                return value
            }
        }
        let attemptCounter = Counter()

        MockURLProtocol.requestHandler = { _ in
            let count = attemptCounter.increment()
            if count < 3 {
                throw URLError(.networkConnectionLost)
            }
            let response = HTTPURLResponse(
                url: URL(string: "https://api.example.com/test")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("{}".utf8))
        }

        let service = NetworkService(session: createMockSession())
        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpMethod = "GET"

        struct EmptyResponse: Codable {}
        _ = try await service.execute(request) as EmptyResponse

        #expect(attemptCounter.value == 3)
    }

    @Test("Does not retry HTTP error responses")
    func testDoesNotRetryHTTPErrors() async throws {
        final class Counter: @unchecked Sendable {
            let lock = NSLock()
            var value = 0
            func increment() -> Int {
                lock.lock()
                defer { lock.unlock() }
                value += 1
                return value
            }
        }
        let attemptCounter = Counter()

        MockURLProtocol.requestHandler = { _ in
            _ = attemptCounter.increment()
            let response = HTTPURLResponse(
                url: URL(string: "https://api.example.com/test")!,
                statusCode: 404,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, nil)
        }

        let service = NetworkService(session: createMockSession())
        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpMethod = "GET"

        struct EmptyResponse: Codable {}

        await #expect(throws: APIError.self) {
            let _: EmptyResponse = try await service.execute(request)
        }

        #expect(attemptCounter.value == 1)
    }

    @Test("Throws circuitBreakerOpen when circuit is open")
    func testCircuitBreakerOpen() async throws {
        let service = NetworkService(session: createMockSession())
        let endpoint = "api.example.com"

        // Trip the circuit by recording 5 failures
        for _ in 1...5 {
            await service.circuitBreaker.recordFailure(for: endpoint)
        }

        var request = URLRequest(url: URL(string: "https://\(endpoint)/test")!)
        request.httpMethod = "GET"

        struct EmptyResponse: Codable {}

        await #expect {
            let _: EmptyResponse = try await service.execute(request)
        } throws: { error in
            guard case APIError.circuitBreakerOpen = error else {
                return false
            }
            return true
        }
    }

    @Test("Decoding failure throws decodingFailure error")
    func testDecodingFailure() async throws {
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: URL(string: "https://api.example.com/test")!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data("invalid json".utf8))
        }

        let service = NetworkService(session: createMockSession())
        var request = URLRequest(url: URL(string: "https://api.example.com/test")!)
        request.httpMethod = "GET"

        struct TestResponse: Codable {
            let field: String
        }

        await #expect {
            let _: TestResponse = try await service.execute(request)
        } throws: { error in
            guard case APIError.decodingFailure = error else {
                return false
            }
            return true
        }
    }
}
