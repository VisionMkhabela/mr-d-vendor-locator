import XCTest
@testable import MrDVendorLocator

final class VendorDecodingTests: XCTestCase {

    func test_givenVendorsJSON_whenDecoded_thenOptionalCoordinatesStayOptional() throws {
        // Given
        let data = Data(Fixtures.vendorsJSON.utf8)

        // When
        let response = try JSONDecoder().decode(VendorsResponseDTO.self, from: data)

        // Then
        XCTAssertEqual(response.vendors.count, 2)

        let capeTown = try XCTUnwrap(response.vendors.first)
        XCTAssertEqual(capeTown.id, "ven-001")
        XCTAssertEqual(capeTown.name, "Mr D Pizza — Cape Town CBD")
        XCTAssertEqual(capeTown.coordinate?.lat, -33.918861)
        XCTAssertEqual(capeTown.coordinate?.lng, 18.423300)
        XCTAssertEqual(capeTown.isFavorite, false)

        let woodstock = try XCTUnwrap(response.vendors.last)
        XCTAssertEqual(woodstock.id, "ven-008")
        XCTAssertNil(woodstock.coordinate)
    }

    func test_givenSessionJSON_whenDecoded_thenTokenIsRead() throws {
        // Given
        let data = Data(Fixtures.sessionJSON.utf8)

        // When
        let session = try JSONDecoder().decode(SessionResponseDTO.self, from: data)

        // Then
        XCTAssertEqual(session.token, "mrD_token_example_123")
        XCTAssertEqual(session.expiresIn, 3600)
    }

    func test_givenMalformedJSON_whenDecoded_thenDecodingFails() {
        // Given
        let data = Data("{".utf8)

        // When / Then
        XCTAssertThrowsError(try JSONDecoder().decode(VendorsResponseDTO.self, from: data))
    }
}
