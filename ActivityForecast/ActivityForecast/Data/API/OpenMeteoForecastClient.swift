import Foundation

struct OpenMeteoForecastClient: Sendable {
    private let client: HTTPClientProtocol
    private let baseURL = "https://api.open-meteo.com/v1/forecast"

    init(client: HTTPClientProtocol) {
        self.client = client
    }

    func fetchDailyForecast(
        latitude: Double,
        longitude: Double,
        timezone: String,
        days: Int
    ) async throws -> DailyForecastDTO {
        guard var components = URLComponents(string: baseURL) else {
            throw APIError.invalidURL
        }
        components.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "timezone", value: timezone),
            URLQueryItem(name: "forecast_days", value: String(days)),
            URLQueryItem(
                name: "daily",
                value: "temperature_2m_max,temperature_2m_min,precipitation_sum,snowfall_sum,wind_speed_10m_max,weather_code"
            )
        ]
        guard let url = components.url else {
            throw APIError.invalidURL
        }

        let data = try await client.data(from: url)
        do {
            let response = try JSONDecoder().decode(ForecastResponseDTO.self, from: data)
            return response.daily
        } catch {
            throw APIError.decoding(error.localizedDescription)
        }
    }
}
