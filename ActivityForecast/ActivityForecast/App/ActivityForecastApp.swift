import SwiftUI

@main
struct ActivityForecastApp: App {
    private let geocodingRepository: GeocodingRepositoryProtocol
    private let weatherRepository: WeatherRepositoryProtocol
    private let rankingService = ActivityRankingService()

    init() {
        let httpClient = URLSessionHTTPClient()
        geocodingRepository = GeocodingRepository(httpClient: httpClient)
        weatherRepository = WeatherRepository(httpClient: httpClient)
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                geocodingRepository: geocodingRepository,
                weatherRepository: weatherRepository,
                rankingService: rankingService
            )
        }
    }
}
