import Foundation
import Observation

@MainActor
@Observable
final class CitySearchViewModel {
    var query = ""
    var state: CitySearchState = .idle

    private let geocodingRepository: GeocodingRepositoryProtocol
    private var searchTask: Task<Void, Never>?

    init(geocodingRepository: GeocodingRepositoryProtocol) {
        self.geocodingRepository = geocodingRepository
    }

    func onQueryChanged(_ newQuery: String) {
        query = newQuery
        searchTask?.cancel()

        let trimmed = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 3 else {
            state = .idle
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            state = .searching
            do {
                let cities = try await geocodingRepository.searchCities(matching: trimmed)
                guard !Task.isCancelled else { return }
                state = cities.isEmpty ? .empty : .results(cities)
            } catch {
                guard !Task.isCancelled else { return }
                state = .failure(error.localizedDescription)
            }
        }
    }
}
