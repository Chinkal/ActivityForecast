import Foundation
import Observation

@MainActor
@Observable
final class ActivityRankingViewModel {
    let city: City
    var state: ActivityRankingState = .idle

    private let weatherRepository: WeatherRepositoryProtocol
    private let rankingService: ActivityRankingService
    private var loadTask: Task<Void, Never>?

    init(
        city: City,
        weatherRepository: WeatherRepositoryProtocol,
        rankingService: ActivityRankingService
    ) {
        self.city = city
        self.weatherRepository = weatherRepository
        self.rankingService = rankingService
    }

    func load() {
        loadTask?.cancel()
        state = .loading

        loadTask = Task {
            do {
                let forecast = try await weatherRepository.fetchDailyForecast(for: city, days: 7)
                guard !Task.isCancelled else { return }
                let ranked = rankingService.rank(weather: forecast)
                state = .loaded(ranked)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failure(error.localizedDescription)
            }
        }
    }
}
