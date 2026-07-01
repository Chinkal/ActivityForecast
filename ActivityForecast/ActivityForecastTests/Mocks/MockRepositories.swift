import Foundation
@testable import ActivityForecast

final class MockGeocodingRepository: GeocodingRepositoryProtocol, @unchecked Sendable {
    var result: Result<[City], Error> = .success([])
    private(set) var lastQuery: String?

    func searchCities(matching query: String) async throws -> [City] {
        lastQuery = query
        return try result.get()
    }
}

final class MockWeatherRepository: WeatherRepositoryProtocol, @unchecked Sendable {
    var result: Result<[DailyWeather], Error> = .success([])
    private(set) var lastCity: City?

    func fetchDailyForecast(for city: City, days: Int) async throws -> [DailyWeather] {
        lastCity = city
        return try result.get()
    }
}
