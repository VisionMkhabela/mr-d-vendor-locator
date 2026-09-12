import XCTest
@testable import MrDVendorLocator

final class LocalJSONHTTPClientTests: XCTestCase {

    func test_givenBundledMockAPI_whenVendorsAreRequested_thenJSONPayloadIsReturned() async throws {
        // Given
        let client = LocalJSONHTTPClient(
            bundle: Bundle(for: LocalJSONHTTPClient.self),
            delayNanoseconds: 0
        )

        // When
        let data = try await client.send(.vendors)
        let response = try JSONDecoder().decode(VendorsResponseDTO.self, from: data)

        // Then
        XCTAssertFalse(response.vendors.isEmpty)
        XCTAssertEqual(response.vendors.first?.id, "ven-001")
        XCTAssertTrue(response.vendors.contains { $0.coordinate == nil })
    }

    func test_givenBundledMockAPI_whenSessionIsRequested_thenDemoTokenIsReturned() async throws {
        // Given
        let client = LocalJSONHTTPClient(
            bundle: Bundle(for: LocalJSONHTTPClient.self),
            delayNanoseconds: 0
        )

        // When
        let data = try await client.send(.session)
        let session = try JSONDecoder().decode(SessionResponseDTO.self, from: data)

        // Then
        XCTAssertEqual(session.token, "mrD_token_example_123")
    }

    func test_givenUnknownPath_whenRequested_thenNotFoundIsThrown() async {
        // Given
        let client = LocalJSONHTTPClient(
            bundle: Bundle(for: LocalJSONHTTPClient.self),
            delayNanoseconds: 0
        )
        let request = HTTPRequest.Builder().method(.get).path("/v1/unknown").build()

        // When / Then
        do {
            _ = try await client.send(request)
            XCTFail("Expected APIError.notFound")
        } catch let error as APIError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Expected APIError.notFound, got \(error)")
        }
    }

    func test_givenTestBundleWithoutJSON_whenVendorsAreRequested_thenNotFoundIsThrown() async {
        // Given
        let client = LocalJSONHTTPClient(
            bundle: Bundle(for: LocalJSONHTTPClientTests.self),
            delayNanoseconds: 0,
            jsonFolder: "Missing"
        )

        // When / Then
        do {
            _ = try await client.send(.vendors)
            XCTFail("Expected APIError.notFound")
        } catch let error as APIError {
            XCTAssertEqual(error, .notFound)
        } catch {
            XCTFail("Expected APIError.notFound, got \(error)")
        }
    }
}
