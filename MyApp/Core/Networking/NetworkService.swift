import Foundation
import OSLog

/// Service for executing HTTP requests with retry and circuit breaking.
actor NetworkService {

    /// Shared singleton instance
    static let shared = NetworkService()

    /// URLSession for making requests
    private let session: URLSession

    /// Retry policy
    private let retryPolicy = RetryPolicy()

    /// Circuit breaker for endpoint resilience
    let circuitBreaker = CircuitBreaker()

    /// Logger for networking events
    private let logger = AppLogger.logger(for: .networking)

    /// Initialize with custom session (for testing) or default
    init(session: URLSession = .shared) {
        self.session = session
    }

    /// Execute an HTTP request with retry and circuit breaking.
    /// - Parameter request: The URLRequest to execute
    /// - Returns: Decoded response of type T
    /// - Throws: APIError on failure
    func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        guard let url = request.url, let host = url.host else {
            throw APIError.invalidRequest("Request URL is invalid")
        }

        // Check circuit breaker
        do {
            _ = try await circuitBreaker.shouldAllowRequest(for: host)
        } catch let error as APIError {
            logger.error("Circuit breaker open for \(host)")
            throw error
        }

        // Attempt request with retries
        var lastError: Error?

        for attempt in 1...retryPolicy.maxAttempts {
            do {
                let (data, response) = try await session.data(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidRequest("Response is not HTTP")
                }

                // Check HTTP status
                guard (200...299).contains(httpResponse.statusCode) else {
                    logger.warning("HTTP error \(httpResponse.statusCode) for \(url)")
                    await circuitBreaker.recordFailure(for: host)
                    throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)
                }

                // Decode response
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    await circuitBreaker.recordSuccess(for: host)
                    logger.info("Request succeeded: \(url)")
                    return decoded
                } catch let decodingError as DecodingError {
                    logger.error("Decoding failed for \(url)")
                    throw APIError.decodingFailure(decodingError)
                }

            } catch let urlError as URLError {
                lastError = urlError

                if retryPolicy.shouldRetry(error: urlError, attempt: attempt) {
                    let delay = retryPolicy.delay(for: attempt)
                    logger.warning("Request failed (attempt \(attempt)), retrying in \(delay)s: \(urlError.localizedDescription)")
                    try await Task.sleep(for: .seconds(delay))
                    continue
                } else {
                    logger.error("Request failed after \(attempt) attempts: \(urlError.localizedDescription)")
                    await circuitBreaker.recordFailure(for: host)
                    throw APIError.networkFailure(urlError)
                }
            } catch {
                // Re-throw APIError and other errors immediately
                throw error
            }
        }

        // Should never reach here, but handle it
        if let urlError = lastError as? URLError {
            await circuitBreaker.recordFailure(for: host)
            throw APIError.networkFailure(urlError)
        }

        throw APIError.invalidRequest("Unknown error occurred")
    }
}
