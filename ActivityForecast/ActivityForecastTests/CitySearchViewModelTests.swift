import Foundation
import Testing
@testable import ActivityForecast

@MainActor
struct CitySearchViewModelTests {
    private let sampleCity = City(
        id: 1,
        name: "London",
        latitude: 51.5,
        longitude: -0.12,
        country: "United Kingdom",
        admin1: "England",
        timezone: "Europe/London",
        elevation: 25
    )

    @Test func shortQueryDoesNotSearch() async {
        let mock = MockGeocodingRepository()
        let viewModel = CitySearchViewModel(geocodingRepository: mock)

        viewModel.onQueryChanged("Lo")
        try? await Task.sleep(for: .milliseconds(400))

        #expect(viewModel.state == .idle)
        #expect(mock.lastQuery == nil)
    }

    @Test func successfulSearchUpdatesResults() async {
        let mock = MockGeocodingRepository()
        mock.result = .success([sampleCity])
        let viewModel = CitySearchViewModel(geocodingRepository: mock)

        viewModel.onQueryChanged("London")
        try? await Task.sleep(for: .milliseconds(500))

        if case .results(let cities) = viewModel.state {
            #expect(cities.count == 1)
            #expect(cities.first?.name == "London")
        } else {
            Issue.record("Expected results state, got \(viewModel.state)")
        }
    }

    @Test func failedSearchUpdatesFailureState() async {
        let mock = MockGeocodingRepository()
        mock.result = .failure(APIError.serverMessage("Network error"))
        let viewModel = CitySearchViewModel(geocodingRepository: mock)

        viewModel.onQueryChanged("London")
        try? await Task.sleep(for: .milliseconds(500))

        if case .failure(let message) = viewModel.state {
            #expect(message.contains("Network error"))
        } else {
            Issue.record("Expected failure state, got \(viewModel.state)")
        }
    }

    @Test func emptyResultsShowEmptyState() async {
        let mock = MockGeocodingRepository()
        mock.result = .success([])
        let viewModel = CitySearchViewModel(geocodingRepository: mock)

        viewModel.onQueryChanged("Xyztown")
        try? await Task.sleep(for: .milliseconds(500))

        #expect(viewModel.state == .empty)
    }
}
