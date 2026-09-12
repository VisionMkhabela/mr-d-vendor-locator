import SwiftUI

struct RootView: View {
    var composition: AppComposition

    var body: some View {
        @Bindable var coordinator = composition.coordinator

        TabView(selection: $coordinator.selectedTab) {
            VendorListView(viewModel: composition.vendorListViewModel)
                .tabItem { Label("Vendors", systemImage: "list.bullet") }
                .tag(AppCoordinator.Tab.vendors)

            VendorMapView(
                viewModel: composition.vendorListViewModel,
                coordinator: coordinator
            )
            .tabItem { Label("Map", systemImage: "map") }
            .tag(AppCoordinator.Tab.map)

            SettingsView(viewModel: composition.settingsViewModel)
                .tabItem { Label("Settings", systemImage: "gearshape") }
                .tag(AppCoordinator.Tab.settings)
        }
        .tint(Color.brandRed)
        .sheet(isPresented: $coordinator.isPlaceSearchPresented) {
            PlaceSearchView(
                viewModel: composition.placeSearchViewModel,
                usesMockPlaces: composition.usesMockPlaces
            ) { place in
                composition.vendorListViewModel.addVendor(from: place)
                coordinator.dismissPlaceSearch()
            }
        }
    }
}
