import SwiftUI

struct RootView: View {
    let geocodingRepository: GeocodingRepositoryProtocol
    let weatherRepository: WeatherRepositoryProtocol
    let rankingService: ActivityRankingService

    @State private var searchViewModel: CitySearchViewModel
    @State private var navigationPath = NavigationPath()

    init(
        geocodingRepository: GeocodingRepositoryProtocol,
        weatherRepository: WeatherRepositoryProtocol,
        rankingService: ActivityRankingService
    ) {
        self.geocodingRepository = geocodingRepository
        self.weatherRepository = weatherRepository
        self.rankingService = rankingService
        _searchViewModel = State(initialValue: CitySearchViewModel(geocodingRepository: geocodingRepository))
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            CitySearchView(viewModel: searchViewModel) { city in
                navigationPath.append(city)
            }
            .navigationDestination(for: City.self) { city in
                ActivityRankingView(
                    viewModel: ActivityRankingViewModel(
                        city: city,
                        weatherRepository: weatherRepository,
                        rankingService: rankingService
                    )
                )
            }
        }
    }
}
