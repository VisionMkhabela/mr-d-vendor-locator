import XCTest
@testable import MrDVendorLocator

final class VendorServiceTests: XCTestCase {

    func test_givenValidVendorsPayload_whenFetched_thenDTOsAreDecoded() async throws {
        // Given
        let client = CapturingHTTPClient()
        client.result = .success(Data(Fixtures.vendorsJSON.utf8))
        let service = VendorService(client: client)

        // When
        let vendors = try await service.fetchVendors()

        // Then
        XCTAssertEqual(client.lastRequest, .vendors)
        XCTAssertEqual(vendors.count, 2)
        XCTAssertEqual(vendors[0].id, "ven-001")
        XCTAssertNil(vendors[1].coordinate)
    }

    func test_givenInvalidVendorsPayload_whenFetched_thenDecodingFailedIsThrown() async {
        // Given
        let client = CapturingHTTPClient()
        client.result = .success(Data("{".utf8))
        let service = VendorService(client: client)

        // When / Then
        do {
            _ = try await service.fetchVendors()
            XCTFail("Expected APIError.decodingFailed")
        } catch let error as APIError {
            XCTAssertEqual(error, .decodingFailed)
        } catch {
            XCTFail("Expected APIError.decodingFailed, got \(error)")
        }
    }

    func test_givenClientFailure_whenVendorsAreFetched_thenErrorPropagates() async {
        // Given
        let client = CapturingHTTPClient()
        client.result = .failure(APIError.unavailable)
        let service = VendorService(client: client)

        // When / Then
        do {
            _ = try await service.fetchVendors()
            XCTFail("Expected APIError.unavailable")
        } catch let error as APIError {
            XCTAssertEqual(error, .unavailable)
        } catch {
            XCTFail("Expected APIError.unavailable, got \(error)")
        }
    }

    func test_givenValidSessionPayload_whenFetched_thenTokenIsReturned() async throws {
        // Given
        let client = CapturingHTTPClient()
        client.result = .success(Data(Fixtures.sessionJSON.utf8))
        let service = VendorService(client: client)

        // When
        let token = try await service.fetchSessionToken()

        // Then
        XCTAssertEqual(client.lastRequest, .session)
        XCTAssertEqual(token, "mrD_token_example_123")
    }

    func test_givenInvalidSessionPayload_whenFetched_thenDecodingFailedIsThrown() async {
        // Given
        let client = CapturingHTTPClient()
        client.result = .success(Data("{\"issuedAt\":\"now\"}".utf8))
        let service = VendorService(client: client)

        // When / Then
        do {
            _ = try await service.fetchSessionToken()
            XCTFail("Expected APIError.decodingFailed")
        } catch let error as APIError {
            XCTAssertEqual(error, .decodingFailed)
        } catch {
            XCTFail("Expected APIError.decodingFailed, got \(error)")
        }
    }
}
