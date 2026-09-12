import SwiftUI

struct VendorListView: View {
    var viewModel: VendorListViewModel

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("MR D Near Me")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            viewModel.presentPlaceSearch()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .accessibilityLabel("Add vendor from place search")
                    }
                }
                .task {
                    if viewModel.vendors.isEmpty {
                        await viewModel.load()
                    }
                }
                .refreshable {
                    await viewModel.reload()
                }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            LoadingView()
        case .failed(let message):
            ErrorStateView(message: message) {
                Task { await viewModel.reload() }
            }
        case .loaded:
            list
        }
    }

    private var list: some View {
        List(viewModel.vendors) { vendor in
            Button {
                viewModel.showOnMap(vendor)
            } label: {
                VendorRow(vendor: vendor) {
                    viewModel.toggleFavorite(id: vendor.id)
                }
            }
            .buttonStyle(.plain)
        }
        .listStyle(.insetGrouped)
        .overlay {
            if viewModel.vendors.isEmpty, viewModel.state == .loaded {
                EmptyStateView(
                    title: "No vendors yet",
                    message: "Pull to refresh or add a place from search.",
                    systemImage: "mappin.slash"
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let message = viewModel.state.errorMessage, !viewModel.vendors.isEmpty {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.brandRed)
            }
        }
    }
}
