import SwiftUI

struct PlaceSearchView: View {
    @Bindable var viewModel: PlaceSearchViewModel
    let usesMockPlaces: Bool
    let onSelect: (PlaceResult) -> Void

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.state {
                case .loading:
                    LoadingView("Searching places…")
                case .failed(let message):
                    ErrorStateView(message: message) {
                        Task { await viewModel.search() }
                    }
                case .idle, .loaded:
                    resultsList
                }
            }
            .navigationTitle("Add a place")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.query, prompt: "Name or address")
            .onSubmit(of: .search) {
                Task { await viewModel.search() }
            }
            .onChange(of: viewModel.query) { _, newValue in
                guard newValue.trimmingCharacters(in: .whitespacesAndNewlines).count >= 3 else { return }
                Task { await viewModel.search() }
            }
            .safeAreaInset(edge: .bottom) {
                if usesMockPlaces {
                    Text("Using mocked Places responses. Add a Google API key in AppConfig to use the live SDK.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Theme.card)
                }
            }
        }
    }

    @ViewBuilder
    private var resultsList: some View {
        if viewModel.results.isEmpty && viewModel.state == .loaded {
            EmptyStateView(
                title: "No places found",
                message: "Try a Cape Town street or suburb name.",
                systemImage: "magnifyingglass"
            )
        } else if viewModel.results.isEmpty {
            EmptyStateView(
                title: "Search for a place",
                message: "Find a name or address, then add it as a vendor with a map marker.",
                systemImage: "mappin.and.ellipse"
            )
        } else {
            List(viewModel.results) { place in
                Button {
                    onSelect(place)
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(place.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(place.address)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}
