import SwiftUI

struct ActivityRankingView: View {
    @Bindable var viewModel: ActivityRankingViewModel

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView("Loading forecast...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loaded(let activities):
                List(activities) { ranked in
                    HStack(alignment: .top, spacing: 12) {
                        Text("#\(ranked.rank)")
                            .font(.title2.bold())
                            .foregroundStyle(.secondary)
                            .frame(width: 36, alignment: .leading)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(ranked.activity.displayName)
                                .font(.headline)
                            Text(ranked.summary)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text("\(Int(ranked.score.rounded()))")
                            .font(.title3.bold())
                            .foregroundStyle(.tint)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            case .failure(let message):
                ContentUnavailableView {
                    Label("Forecast Failed", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") {
                        viewModel.load()
                    }
                }
            }
        }
        .navigationTitle(viewModel.city.name)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if case .idle = viewModel.state {
                viewModel.load()
            }
        }
    }
}
