import XCTest
@testable import MrDVendorLocator

final class VendorTests: XCTestCase {

    func test_givenVendorWithCoordinate_whenHasCoordinateIsRead_thenItIsTrue() {
        // Given
        let vendor = Vendor.sample

        // When
        let hasCoordinate = vendor.hasCoordinate

        // Then
        XCTAssertTrue(hasCoordinate)
        XCTAssertEqual(vendor.coordinate?.latitude, -33.918861)
        XCTAssertEqual(vendor.coordinate?.longitude, 18.423300)
    }

    func test_givenVendorWithoutCoordinate_whenHasCoordinateIsRead_thenItIsFalse() {
        // Given
        let vendor = Vendor(
            id: "ven-008",
            name: "Mr D Express — Woodstock Kitchen",
            address: "66 Albert Rd, Woodstock, Cape Town, 7925",
            coordinate: nil,
            isFavorite: false,
            updatedAt: .now
        )

        // When / Then
        XCTAssertFalse(vendor.hasCoordinate)
    }
}
