import XCTest
@testable import MrDVendorLocator

final class VendorDecodingTests: XCTestCase {

    func testDecodesVendorListIncludingOptionalCoordinates() throws {
        let data = Data(Self.sampleJSON.utf8)
        let response = try JSONDecoder().decode(VendorsResponseDTO.self, from: data)

        XCTAssertEqual(response.vendors.count, 2)

        let capeTown = try XCTUnwrap(response.vendors.first)
        XCTAssertEqual(capeTown.id, "ven-001")
        XCTAssertEqual(capeTown.name, "Mr D Pizza — Cape Town CBD")
        XCTAssertEqual(capeTown.coordinate?.lat, -33.918861)
        XCTAssertEqual(capeTown.coordinate?.lng, 18.423300)

        let woodstock = try XCTUnwrap(response.vendors.last)
        XCTAssertEqual(woodstock.id, "ven-008")
        XCTAssertNil(woodstock.coordinate)
    }

    func testFactoryMapsDTOAndAppliesLocalFavorites() throws {
        let dto = VendorDTO(
            id: "ven-001",
            name: "Mr D Pizza — Cape Town CBD",
            address: "12 Loop St, Cape Town, 8000",
            coordinate: CoordinateDTO(lat: -33.918861, lng: 18.423300),
            isFavorite: false,
            updatedAt: "2025-06-01T12:00:00Z"
        )

        let vendor = VendorFactory.make(from: dto, favoriteIDs: ["ven-001"])

        XCTAssertEqual(vendor.id, "ven-001")
        XCTAssertEqual(vendor.coordinate?.latitude, -33.918861)
        XCTAssertTrue(vendor.isFavorite)
        XCTAssertEqual(vendor.updatedAt, DateParsing.iso8601("2025-06-01T12:00:00Z"))
    }

    private static let sampleJSON = """
    {
      "vendors": [
        {
          "id": "ven-001",
          "name": "Mr D Pizza — Cape Town CBD",
          "address": "12 Loop St, Cape Town, 8000",
          "coordinate": { "lat": -33.918861, "lng": 18.423300 },
          "isFavorite": false,
          "updatedAt": "2025-06-01T12:00:00Z"
        },
        {
          "id": "ven-008",
          "name": "Mr D Express — Woodstock Kitchen",
          "address": "66 Albert Rd, Woodstock, Cape Town, 7925",
          "isFavorite": false,
          "updatedAt": "2025-06-08T13:00:00Z"
        }
      ]
    }
    """
}

@MainActor
final class VendorListViewModelTests: XCTestCase {

    func testLoadPopulatesVendorsAndFavoriteTogglePersists() async {
        let service = StubVendorService(dtos: [Self.sampleDTO])
        let favorites = InMemoryFavoriteStore()
        let viewModel = VendorListViewModel(service: service, favorites: favorites)

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.vendors.count, 1)
        XCTAssertFalse(viewModel.vendors[0].isFavorite)

        viewModel.toggleFavorite(id: "ven-001")

        XCTAssertTrue(viewModel.vendors[0].isFavorite)
        XCTAssertEqual(favorites.ids(), ["ven-001"])
    }

    func testLoadSurfacesUserFriendlyError() async {
        let service = StubVendorService(error: APIError.unavailable)
        let viewModel = VendorListViewModel(service: service, favorites: InMemoryFavoriteStore())

        await viewModel.load()

        XCTAssertEqual(viewModel.vendors, [])
        XCTAssertEqual(viewModel.state, .failed(APIError.unavailable.localizedDescription))
    }

    private static let sampleDTO = VendorDTO(
        id: "ven-001",
        name: "Mr D Pizza — Cape Town CBD",
        address: "12 Loop St, Cape Town, 8000",
        coordinate: CoordinateDTO(lat: -33.918861, lng: 18.423300),
        isFavorite: false,
        updatedAt: "2025-06-01T12:00:00Z"
    )
}

private struct StubVendorService: VendorServing {
    var dtos: [VendorDTO] = []
    var error: Error?
    var token = "mrD_token_example_123"

    func fetchVendors() async throws -> [VendorDTO] {
        if let error { throw error }
        return dtos
    }

    func fetchSessionToken() async throws -> String {
        token
    }
}
