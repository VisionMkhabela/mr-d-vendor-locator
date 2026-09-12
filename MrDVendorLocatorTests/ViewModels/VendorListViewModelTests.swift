import XCTest
@testable import MrDVendorLocator

@MainActor
final class VendorListViewModelTests: XCTestCase {

    func test_givenSuccessfulService_whenLoadCompletes_thenVendorsAreMappedAndStateIsLoaded() async {
        // Given
        let service = StubVendorService(dtos: [Fixtures.capeTownDTO, Fixtures.woodstockDTO])
        let viewModel = VendorListViewModel(service: service, favorites: InMemoryFavoriteStore())

        // When
        await viewModel.load()

        // Then
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.vendors.map(\.id), ["ven-001", "ven-008"])
        XCTAssertTrue(viewModel.vendors[0].hasCoordinate)
        XCTAssertFalse(viewModel.vendors[1].hasCoordinate)
    }

    func test_givenStoredFavorites_whenLoadCompletes_thenMatchingVendorsAreFavorited() async {
        // Given
        let service = StubVendorService(dtos: [Fixtures.capeTownDTO])
        let favorites = InMemoryFavoriteStore(["ven-001"])
        let viewModel = VendorListViewModel(service: service, favorites: favorites)

        // When
        await viewModel.load()

        // Then
        XCTAssertTrue(viewModel.vendors[0].isFavorite)
    }

    func test_givenServiceFailure_whenLoadCompletes_thenFailedStateSurfacesUserCopy() async {
        // Given
        let service = StubVendorService(error: APIError.unavailable)
        let viewModel = VendorListViewModel(service: service, favorites: InMemoryFavoriteStore())

        // When
        await viewModel.load()

        // Then
        XCTAssertEqual(viewModel.vendors, [])
        XCTAssertEqual(viewModel.state, .failed(APIError.unavailable.localizedDescription))
        XCTAssertEqual(viewModel.state.errorMessage, APIError.unavailable.localizedDescription)
    }

    func test_givenLoadedVendors_whenFavoriteIsToggled_thenStorePersistsTheID() async {
        // Given
        let favorites = InMemoryFavoriteStore()
        let viewModel = VendorListViewModel(
            service: StubVendorService(dtos: [Fixtures.capeTownDTO]),
            favorites: favorites
        )
        await viewModel.load()

        // When
        viewModel.toggleFavorite(id: "ven-001")

        // Then
        XCTAssertTrue(viewModel.vendors[0].isFavorite)
        XCTAssertEqual(favorites.ids(), ["ven-001"])
    }

    func test_givenFavoriteVendor_whenToggledAgain_thenIDIsRemovedFromStore() async {
        // Given
        let favorites = InMemoryFavoriteStore(["ven-001"])
        let viewModel = VendorListViewModel(
            service: StubVendorService(dtos: [Fixtures.capeTownDTO]),
            favorites: favorites
        )
        await viewModel.load()

        // When
        viewModel.toggleFavorite(id: "ven-001")

        // Then
        XCTAssertFalse(viewModel.vendors[0].isFavorite)
        XCTAssertTrue(favorites.ids().isEmpty)
    }

    func test_givenUnknownVendorID_whenFavoriteIsToggled_thenStateIsUnchanged() async {
        // Given
        let favorites = InMemoryFavoriteStore()
        let viewModel = VendorListViewModel(
            service: StubVendorService(dtos: [Fixtures.capeTownDTO]),
            favorites: favorites
        )
        await viewModel.load()

        // When
        viewModel.toggleFavorite(id: "missing")

        // Then
        XCTAssertFalse(viewModel.vendors[0].isFavorite)
        XCTAssertTrue(favorites.ids().isEmpty)
    }

    func test_givenMixOfCoordinates_whenMappableVendorsAreRead_thenVendorsWithoutPinsAreExcluded() async {
        // Given
        let viewModel = VendorListViewModel(
            service: StubVendorService(dtos: [Fixtures.capeTownDTO, Fixtures.woodstockDTO]),
            favorites: InMemoryFavoriteStore()
        )
        await viewModel.load()

        // When
        let mappable = viewModel.mappableVendors

        // Then
        XCTAssertEqual(mappable.map(\.id), ["ven-001"])
    }

    func test_givenLoadedVendors_whenVendorIsLookedUp_thenMatchingValueIsReturned() async {
        // Given
        let viewModel = VendorListViewModel(
            service: StubVendorService(dtos: [Fixtures.capeTownDTO]),
            favorites: InMemoryFavoriteStore()
        )
        await viewModel.load()

        // When / Then
        XCTAssertEqual(viewModel.vendor(id: "ven-001")?.name, Fixtures.capeTownDTO.name)
        XCTAssertNil(viewModel.vendor(id: "missing"))
        XCTAssertNil(viewModel.vendor(id: nil))
    }

    func test_givenRouter_whenVendorIsShownOnMap_thenCoordinatorReceivesTheID() async throws {
        // Given
        let router = SpyVendorRouter()
        let viewModel = VendorListViewModel(
            service: StubVendorService(dtos: [Fixtures.capeTownDTO]),
            favorites: InMemoryFavoriteStore(),
            router: router
        )
        await viewModel.load()
        let vendor = try XCTUnwrap(viewModel.vendors.first)

        // When
        viewModel.showOnMap(vendor)

        // Then
        XCTAssertEqual(router.shownVendorID, "ven-001")
    }

    func test_givenRouter_whenPlaceSearchIsPresented_thenCoordinatorIsNotified() {
        // Given
        let router = SpyVendorRouter()
        let viewModel = VendorListViewModel(
            service: StubVendorService(),
            favorites: InMemoryFavoriteStore(),
            router: router
        )

        // When
        viewModel.presentPlaceSearch()

        // Then
        XCTAssertTrue(router.didPresentPlaceSearch)
    }

    func test_givenPlaceResult_whenVendorIsAdded_thenItIsInsertedFirstAndShownOnMap() {
        // Given
        let router = SpyVendorRouter()
        let viewModel = VendorListViewModel(
            service: StubVendorService(dtos: [Fixtures.capeTownDTO]),
            favorites: InMemoryFavoriteStore(),
            router: router
        )

        // When
        viewModel.addVendor(from: Fixtures.kloofPlace)

        // Then
        XCTAssertEqual(viewModel.vendors.first?.name, Fixtures.kloofPlace.name)
        XCTAssertEqual(viewModel.vendors.first?.coordinate, Fixtures.kloofPlace.coordinate)
        XCTAssertEqual(router.shownVendorID, viewModel.vendors.first?.id)
    }

    func test_givenLoadedList_whenReloaded_thenServiceIsAskedAgain() async {
        // Given
        let service = StubVendorService(dtos: [Fixtures.capeTownDTO])
        let viewModel = VendorListViewModel(service: service, favorites: InMemoryFavoriteStore())
        await viewModel.load()

        // When
        await viewModel.reload()

        // Then
        XCTAssertEqual(service.fetchVendorsCallCount, 2)
        XCTAssertEqual(viewModel.state, .loaded)
    }
}
