import Testing
import Foundation
@testable import MyApp

@Suite("APIError Tests")
struct APIErrorTests {

    @Test("Network failure provides descriptive message")
    func testNetworkFailureMessage() {
        let urlError = URLError(.networkConnectionLost)
        let error = APIError.networkFailure(urlError)
        let description = error.errorDescription ?? ""
        #expect(description.contains("Network error"))
    }

    @Test("Circuit breaker open provides endpoint and reset time")
    func testCircuitBreakerMessage() {
        let resetDate = Date(timeIntervalSinceNow: 60)
        let error = APIError.circuitBreakerOpen(endpoint: "api.example.com", resetAt: resetDate)
        let description = error.errorDescription ?? ""
        #expect(description.contains("api.example.com"))
        #expect(description.contains("temporarily unavailable"))
    }

    @Test("HTTP error provides status code")
    func testHTTPErrorMessage() {
        let error = APIError.httpError(statusCode: 404, data: nil)
        let description = error.errorDescription ?? ""
        #expect(description.contains("404"))
    }

    @Test("Decoding failure provides message")
    func testDecodingFailureMessage() {
        let decodingError = DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: [], debugDescription: "test")
        )
        let error = APIError.decodingFailure(decodingError)
        let description = error.errorDescription ?? ""
        #expect(description.contains("Response format invalid"))
    }

    @Test("Invalid request provides custom message")
    func testInvalidRequestMessage() {
        let error = APIError.invalidRequest("Bad URL")
        let description = error.errorDescription ?? ""
        #expect(description.contains("Bad URL"))
    }
}
