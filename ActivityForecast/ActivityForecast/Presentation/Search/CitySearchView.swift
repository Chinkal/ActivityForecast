import SwiftUI

struct CitySearchView: View {
    @Bindable var viewModel: CitySearchViewModel
    let onCitySelected: (City) -> Void

    var body: some View {
        VStack(spacing: 0) {
            searchField

            switch viewModel.state {
            case .idle:
                idleContent
            case .searching:
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .results(let cities):
                List(cities) { city in
                    Button {
                        onCitySelected(city)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(city.name)
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(city.displaySubtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .listStyle(.plain)
            case .empty:
                ContentUnavailableView(
                    "No Cities Found",
                    systemImage: "magnifyingglass",
                    description: Text("Try a different search term.")
                )
            case .failure(let message):
                ContentUnavailableView {
                    Label("Search Failed", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") {
                        viewModel.onQueryChanged(viewModel.query)
                    }
                }
            }
        }
        .navigationTitle("Activity Forecast")
    }

    private var searchField: some View {
        TextField("Search for a city", text: Binding(
            get: { viewModel.query },
            set: { viewModel.onQueryChanged($0) }
        ))
        .textFieldStyle(.roundedBorder)
        .padding()
        .autocorrectionDisabled()
        .textInputAutocapitalization(.words)
    }

    private var idleContent: some View {
        ContentUnavailableView(
            "Find a City",
            systemImage: "location.magnifyingglass",
            description: Text("Enter at least 3 characters to search.")
        )
    }
}
