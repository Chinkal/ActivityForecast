import Foundation

struct WeatherRepository: WeatherRepositoryProtocol {
    private let client: OpenMeteoForecastClient

    init(httpClient: HTTPClientProtocol) {
        self.client = OpenMeteoForecastClient(client: httpClient)
    }

    func fetchDailyForecast(for city: City, days: Int) async throws -> [DailyWeather] {
        let daily = try await client.fetchDailyForecast(
            latitude: city.latitude,
            longitude: city.longitude,
            timezone: city.timezone,
            days: days
        )
        return daily.toDomain()
    }
}
