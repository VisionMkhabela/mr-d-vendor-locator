import XCTest
@testable import MrDVendorLocator

final class MockPlacesSearchServiceTests: XCTestCase {

    func test_givenEmptyQuery_whenSearched_thenFullCatalogIsReturned() async throws {
        // Given
        let catalog = [Fixtures.kloofPlace]
        let service = MockPlacesSearchService(catalog: catalog)

        // When
        let results = try await service.search(query: "   ")

        // Then
        XCTAssertEqual(results, catalog)
    }

    func test_givenNameFragment_whenSearched_thenMatchingPlacesAreReturned() async throws {
        // Given
        let service = MockPlacesSearchService(catalog: PlaceResult.southAfricaSamples)

        // When
        let results = try await service.search(query: "kloof")

        // Then
        XCTAssertEqual(results.map(\.id), ["place-kloof"])
    }

    func test_givenAddressFragment_whenSearched_thenMatchingPlacesAreReturned() async throws {
        // Given
        let service = MockPlacesSearchService(catalog: PlaceResult.southAfricaSamples)

        // When
        let results = try await service.search(query: "Umhlanga")

        // Then
        XCTAssertEqual(results.map(\.id), ["place-umhlanga"])
    }

    func test_givenUnknownQuery_whenSearched_thenResultsAreEmpty() async throws {
        // Given
        let service = MockPlacesSearchService(catalog: PlaceResult.southAfricaSamples)

        // When
        let results = try await service.search(query: "xyz-no-match")

        // Then
        XCTAssertTrue(results.isEmpty)
    }
}

final class PlacesServiceFactoryTests: XCTestCase {

    func test_givenLiveFlagOff_whenFactoryMakesService_thenMockImplementationIsUsed() {
        // Given / When
        let service = PlacesServiceFactory.make(isLive: false)

        // Then
        XCTAssertTrue(service is MockPlacesSearchService)
    }

    func test_givenLiveFlagOn_whenFactoryMakesService_thenGoogleImplementationIsUsed() {
        // Given / When
        let service = PlacesServiceFactory.make(isLive: true)

        // Then
        XCTAssertTrue(service is GooglePlacesSearchService)
    }
}
