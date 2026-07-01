import Foundation

protocol WeatherRepositoryProtocol: Sendable {
    func fetchDailyForecast(for city: City, days: Int) async throws -> [DailyWeather]
}
