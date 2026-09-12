import XCTest
@testable import MrDVendorLocator

final class APIErrorTests: XCTestCase {

    func test_givenEachCase_whenLocalizedDescriptionIsRead_thenCopyIsUserFacing() {
        XCTAssertEqual(
            APIError.invalidResponse.localizedDescription,
            "The server returned an unexpected response."
        )
        XCTAssertEqual(
            APIError.notFound.localizedDescription,
            "We couldn't find that resource."
        )
        XCTAssertEqual(
            APIError.decodingFailed.localizedDescription,
            "We couldn't read the vendor data."
        )
        XCTAssertEqual(
            APIError.unauthorized.localizedDescription,
            "Your session token was rejected. Add a valid token in Settings."
        )
        XCTAssertEqual(
            APIError.unavailable.localizedDescription,
            "The service is temporarily unavailable. Please try again."
        )
    }
}
