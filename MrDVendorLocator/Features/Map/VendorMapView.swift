import SwiftUI

struct VendorMapView: View {
    var viewModel: VendorListViewModel
    var coordinator: AppCoordinator
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                GoogleMapView(
                    vendors: viewModel.mappableVendors,
                    selectedVendorID: coordinator.selectedVendorID,
                    colorScheme: colorScheme,
                    onSelect: { coordinator.selectVendor($0) }
                )
                .ignoresSafeArea(edges: .bottom)

                VStack(spacing: 12) {
                    if !AppConfig.isGoogleAPIKeyConfigured {
                        keyBanner
                    }

                    if let vendor = viewModel.vendor(id: coordinator.selectedVendorID) {
                        selectedCard(vendor)
                    }
                }
                .padding()
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.presentPlaceSearch()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .accessibilityLabel("Search places")
                }
            }
            .task {
                if viewModel.vendors.isEmpty {
                    await viewModel.load()
                }
            }
        }
    }

    private var keyBanner: some View {
        Text("Add a Google Maps API key in AppConfig.swift to load live map tiles.")
            .font(.footnote)
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func selectedCard(_ vendor: Vendor) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(vendor.name)
                    .font(.headline)
                Text(vendor.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            FavoriteButton(isFavorite: vendor.isFavorite) {
                viewModel.toggleFavorite(id: vendor.id)
            }
        }
        .padding()
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }
}
