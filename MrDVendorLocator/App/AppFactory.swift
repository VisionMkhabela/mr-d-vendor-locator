import Foundation
import GoogleMaps
import GooglePlaces
import Observation

@MainActor
@Observable
final class AppComposition {
    let coordinator: AppCoordinator
    let vendorListViewModel: VendorListViewModel
    let settingsViewModel: SettingsViewModel
    let placeSearchViewModel: PlaceSearchViewModel
    let usesMockPlaces: Bool

    init(
        coordinator: AppCoordinator,
        vendorListViewModel: VendorListViewModel,
        settingsViewModel: SettingsViewModel,
        placeSearchViewModel: PlaceSearchViewModel,
        usesMockPlaces: Bool
    ) {
        self.coordinator = coordinator
        self.vendorListViewModel = vendorListViewModel
        self.settingsViewModel = settingsViewModel
        self.placeSearchViewModel = placeSearchViewModel
        self.usesMockPlaces = usesMockPlaces
        vendorListViewModel.attach(router: coordinator)
    }
}

enum AppFactory {
    @MainActor
    static func make() -> AppComposition {
        
        GoogleServicesBootstrap.configure()
        
        let tokenStore = KeychainTokenStore()
        let httpClient: HTTPClient = AuthenticatedHTTPClient(
            client: LocalJSONHTTPClient(),
            tokenStore: tokenStore
        )
        let vendorService = VendorService(client: httpClient)
        let usesMockPlaces = !AppConfig.isGoogleAPIKeyConfigured
        let places = PlacesServiceFactory.make(isLive: !usesMockPlaces)

        return AppComposition(
            coordinator: AppCoordinator(),
            vendorListViewModel: VendorListViewModel(
                service: vendorService,
                favorites: UserDefaultsFavoriteStore()
            ),
            settingsViewModel: SettingsViewModel(
                tokenStore: tokenStore,
                service: vendorService
            ),
            placeSearchViewModel: PlaceSearchViewModel(places: places),
            usesMockPlaces: usesMockPlaces
        )
    }
}

enum GoogleServicesBootstrap {
    static func configure() {
        GMSServices.provideAPIKey(AppConfig.googleMapsAPIKey)
        GMSPlacesClient.provideAPIKey(AppConfig.googleMapsAPIKey)
    }
}
