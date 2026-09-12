import XCTest
@testable import MrDVendorLocator

final class VendorFactoryTests: XCTestCase {

    func test_givenDTOWithCoordinates_whenMapped_thenDomainVendorKeepsLocation() {
        // Given
        let dto = Fixtures.capeTownDTO

        // When
        let vendor = VendorFactory.make(from: dto, favoriteIDs: [])

        // Then
        XCTAssertEqual(vendor.id, "ven-001")
        XCTAssertEqual(vendor.name, dto.name)
        XCTAssertEqual(vendor.address, dto.address)
        XCTAssertEqual(vendor.coordinate, Coordinate(latitude: -33.918861, longitude: 18.423300))
        XCTAssertFalse(vendor.isFavorite)
        XCTAssertEqual(vendor.updatedAt, DateParsing.iso8601(dto.updatedAt))
    }

    func test_givenLocalFavoriteID_whenMapped_thenVendorIsFavoriteEvenIfDTOIsNot() {
        // Given
        let dto = Fixtures.capeTownDTO

        // When
        let vendor = VendorFactory.make(from: dto, favoriteIDs: ["ven-001"])

        // Then
        XCTAssertTrue(vendor.isFavorite)
    }

    func test_givenDTOAlreadyFavorite_whenMappedWithoutLocalIDs_thenVendorStaysFavorite() {
        // Given
        let dto = VendorDTO(
            id: "ven-002",
            name: "Mr D Burgers — V&A Waterfront",
            address: "Dock Rd, V&A Waterfront, Cape Town, 8001",
            coordinate: CoordinateDTO(lat: -33.903691, lng: 18.420406),
            isFavorite: true,
            updatedAt: "2025-06-02T09:30:00Z"
        )

        // When
        let vendor = VendorFactory.make(from: dto, favoriteIDs: [])

        // Then
        XCTAssertTrue(vendor.isFavorite)
    }

    func test_givenDTOWithoutCoordinates_whenMapped_thenCoordinateIsNil() {
        // Given / When
        let vendor = VendorFactory.make(from: Fixtures.woodstockDTO, favoriteIDs: [])

        // Then
        XCTAssertNil(vendor.coordinate)
        XCTAssertFalse(vendor.hasCoordinate)
    }

    func test_givenInvalidUpdatedAt_whenMapped_thenTimestampFallsBackToNow() {
        // Given
        let dto = VendorDTO(
            id: "ven-009",
            name: "Unknown Kitchen",
            address: "Cape Town",
            coordinate: nil,
            isFavorite: false,
            updatedAt: "not-a-date"
        )

        // When
        let vendor = VendorFactory.make(from: dto, favoriteIDs: [])

        // Then
        XCTAssertEqual(vendor.updatedAt.timeIntervalSinceNow, 0, accuracy: 1.5)
    }

    func test_givenPlaceResult_whenMapped_thenVendorIsMappableAndNotFavorite() {
        // Given
        let place = Fixtures.kloofPlace

        // When
        let vendor = VendorFactory.make(from: place)

        // Then
        XCTAssertTrue(vendor.id.hasPrefix("ven-"))
        XCTAssertEqual(vendor.name, place.name)
        XCTAssertEqual(vendor.address, place.address)
        XCTAssertEqual(vendor.coordinate, place.coordinate)
        XCTAssertFalse(vendor.isFavorite)
        XCTAssertTrue(vendor.hasCoordinate)
    }
}
