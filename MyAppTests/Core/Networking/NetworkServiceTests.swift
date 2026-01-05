import Testing
import Foundation
@testable import MyApp

@Suite("NetworkService Tests")
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
        var attemptCount = 0

        MockURLProtocol.requestHandler = { _ in
            attemptCount += 1
            if attemptCount < 3 {
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

        #expect(attemptCount == 3)
    }

    @Test("Does not retry HTTP error responses")
    func testDoesNotRetryHTTPErrors() async throws {
        var attemptCount = 0

        MockURLProtocol.requestHandler = { _ in
            attemptCount += 1
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

        #expect(attemptCount == 1)
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

        await #expect(throws: APIError.circuitBreakerOpen) {
            let _: EmptyResponse = try await service.execute(request)
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

        await #expect(throws: APIError.decodingFailure) {
            let _: TestResponse = try await service.execute(request)
        }
    }
}
