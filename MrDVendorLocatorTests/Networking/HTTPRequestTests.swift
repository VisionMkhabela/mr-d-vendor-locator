import XCTest
@testable import MrDVendorLocator

final class HTTPRequestTests: XCTestCase {

    func test_givenBuilderDefaults_whenBuilt_thenRequestIsGETWithJSONAcceptHeader() {
        // Given
        let builder = HTTPRequest.Builder()

        // When
        let request = builder.build()

        // Then
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "/")
        XCTAssertEqual(request.headers["Accept"], "application/json")
    }

    func test_givenCustomMethodPathAndHeader_whenBuilt_thenValuesAreCopiedOntoTheRequest() {
        // Given / When
        let request = HTTPRequest.Builder()
            .method(.post)
            .path("/v1/session")
            .header("Authorization", "Bearer demo")
            .build()

        // Then
        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.path, "/v1/session")
        XCTAssertEqual(request.headers["Authorization"], "Bearer demo")
        XCTAssertEqual(request.headers["Accept"], "application/json")
    }

    func test_givenVendorsFactory_whenCreated_thenItTargetsGETVendors() {
        // Given / When
        let request = HTTPRequest.vendors

        // Then
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "/v1/vendors")
    }

    func test_givenSessionFactory_whenCreated_thenItTargetsGETSession() {
        // Given / When
        let request = HTTPRequest.session

        // Then
        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.path, "/v1/session")
    }
}
