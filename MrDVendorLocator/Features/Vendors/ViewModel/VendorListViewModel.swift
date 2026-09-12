import Foundation
import Observation

@MainActor
@Observable
final class VendorListViewModel {
    private(set) var vendors: [Vendor] = []
    private(set) var state: LoadState = .idle

    @ObservationIgnored
    private let service: VendorServing
    @ObservationIgnored
    private let favorites: FavoriteStoring
    @ObservationIgnored
    private weak var router: VendorRouting?

    init(
        service: VendorServing,
        favorites: FavoriteStoring,
        router: VendorRouting? = nil
    ) {
        self.service = service
        self.favorites = favorites
        self.router = router
    }

    func attach(router: VendorRouting) {
        self.router = router
    }

    func load() async {
        state = .loading
        do {
            let dtos = try await service.fetchVendors()
            let favoriteIDs = favorites.ids()
            vendors = dtos.map { VendorFactory.make(from: $0, favoriteIDs: favoriteIDs) }
            state = .loaded
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func reload() async {
        await load()
    }

    func toggleFavorite(id: Vendor.ID) {
        guard let index = vendors.firstIndex(where: { $0.id == id }) else { return }
        vendors[index].isFavorite.toggle()

        var ids = favorites.ids()
        if vendors[index].isFavorite {
            ids.insert(id)
        } else {
            ids.remove(id)
        }
        favorites.save(ids)
    }

    func showOnMap(_ vendor: Vendor) {
        router?.showOnMap(vendorID: vendor.id)
    }

    func presentPlaceSearch() {
        router?.presentPlaceSearch()
    }

    func addVendor(from place: PlaceResult) {
        let vendor = VendorFactory.make(from: place)
        vendors.insert(vendor, at: 0)
        router?.showOnMap(vendorID: vendor.id)
    }

    func vendor(id: Vendor.ID?) -> Vendor? {
        vendors.first { $0.id == id }
    }

    var mappableVendors: [Vendor] {
        vendors.filter(\.hasCoordinate)
    }
}
