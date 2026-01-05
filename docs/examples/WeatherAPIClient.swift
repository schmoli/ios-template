import Foundation

// MARK: - Example API Client

/// Example API client for a weather service.
///
/// This demonstrates how to implement the APIClient protocol
/// for your specific API. Copy this pattern for your own clients.
struct WeatherAPIClient: APIClient {

    let baseURL: URL
    let apiKey: String

    init(baseURL: URL, apiKey: String) {
        self.baseURL = baseURL
        self.apiKey = apiKey
    }

    func request<T: Decodable>(
        _ method: HTTPMethod,
        path: String,
        body: Encodable? = nil
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")

        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return try await NetworkService.shared.execute(request)
    }
}

// MARK: - Response Models

struct WeatherResponse: Codable {
    let temperature: Double
    let condition: String
    let humidity: Double
}

// MARK: - Usage Example

/*
 // In your feature:

 let client = WeatherAPIClient(
     baseURL: URL(string: "https://api.weather.example.com")!,
     apiKey: "your-api-key"
 )

 let weather: WeatherResponse = try await client.request(
     .get,
     path: "/current",
     body: nil
 )

 print("Temperature: \(weather.temperature)°C")
 */
