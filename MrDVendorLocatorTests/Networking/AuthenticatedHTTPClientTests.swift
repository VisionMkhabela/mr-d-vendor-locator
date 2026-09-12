import XCTest
@testable import MrDVendorLocator

final class AuthenticatedHTTPClientTests: XCTestCase {

    func test_givenStoredToken_whenRequestIsSent_thenBearerHeaderIsAttached() async throws {
        // Given
        let inner = CapturingHTTPClient()
        inner.result = .success(Data("ok".utf8))
        let store = InMemoryTokenStore(token: "mrD_token_example_123")
        let client = AuthenticatedHTTPClient(client: inner, tokenStore: store)

        // When
        let data = try await client.send(.vendors)

        // Then
        XCTAssertEqual(String(data: data, encoding: .utf8), "ok")
        XCTAssertEqual(inner.lastRequest?.headers["Authorization"], "Bearer mrD_token_example_123")
        XCTAssertEqual(inner.lastRequest?.path, "/v1/vendors")
    }

    func test_givenNoToken_whenRequestIsSent_thenAuthorizationHeaderIsOmitted() async throws {
        // Given
        let inner = CapturingHTTPClient()
        let client = AuthenticatedHTTPClient(client: inner, tokenStore: InMemoryTokenStore())

        // When
        _ = try await client.send(.vendors)

        // Then
        XCTAssertNil(inner.lastRequest?.headers["Authorization"])
        XCTAssertEqual(inner.lastRequest?.headers["Accept"], "application/json")
    }

    func test_givenEmptyToken_whenRequestIsSent_thenAuthorizationHeaderIsOmitted() async throws {
        // Given
        let inner = CapturingHTTPClient()
        let client = AuthenticatedHTTPClient(client: inner, tokenStore: InMemoryTokenStore(token: ""))

        // When
        _ = try await client.send(.session)

        // Then
        XCTAssertNil(inner.lastRequest?.headers["Authorization"])
    }

    func test_givenTokenStoreFailure_whenRequestIsSent_thenErrorPropagatesAndInnerClientIsNotCalled() async {
        // Given
        let inner = CapturingHTTPClient()
        let store = InMemoryTokenStore()
        store.error = KeychainError.unexpectedStatus(-1)
        let client = AuthenticatedHTTPClient(client: inner, tokenStore: store)

        // When / Then
        do {
            _ = try await client.send(.vendors)
            XCTFail("Expected the token store error")
        } catch {
            XCTAssertEqual(inner.sendCount, 0)
        }
    }
}
