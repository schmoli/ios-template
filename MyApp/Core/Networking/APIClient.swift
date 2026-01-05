import Foundation

/// Protocol for making HTTP requests with automatic retry and circuit breaking.
///
/// Conform to this protocol in your feature's API client to get:
/// - Automatic retries on network failures (3 attempts with exponential backoff)
/// - Circuit breaking (stops trying after 5 consecutive failures)
/// - Structured error handling
///
/// ## Example
///
/// ```swift
/// struct WeatherAPIClient: APIClient {
///     let baseURL: URL
///     let apiKey: String
///
///     func request<T: Decodable>(
///         _ method: HTTPMethod,
///         path: String,
///         body: Encodable? = nil
///     ) async throws -> T {
///         var request = URLRequest(url: baseURL.appendingPathComponent(path))
///         request.httpMethod = method.rawValue
///         request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
///
///         return try await NetworkService.shared.execute(request)
///     }
/// }
/// ```
protocol APIClient {
    /// Make an HTTP request and decode the response.
    ///
    /// - Parameters:
    ///   - method: HTTP method (GET, POST, etc.)
    ///   - path: API endpoint path (e.g., "/api/forecast")
    ///   - body: Optional request body (will be JSON encoded)
    /// - Returns: Decoded response of type `T`
    /// - Throws: `APIError` on failure
    func request<T: Decodable>(
        _ method: HTTPMethod,
        path: String,
        body: Encodable?
    ) async throws -> T
}
