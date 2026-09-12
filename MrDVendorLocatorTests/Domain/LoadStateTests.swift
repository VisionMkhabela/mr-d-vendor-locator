import XCTest
@testable import MrDVendorLocator

final class LoadStateTests: XCTestCase {

    func test_givenFailedState_whenErrorMessageIsRead_thenItReturnsTheFailureText() {
        // Given
        let state = LoadState.failed("The service is temporarily unavailable. Please try again.")

        // When / Then
        XCTAssertEqual(state.errorMessage, "The service is temporarily unavailable. Please try again.")
        XCTAssertFalse(state.isLoading)
    }

    func test_givenNonFailedStates_whenErrorMessageIsRead_thenItIsNil() {
        XCTAssertNil(LoadState.idle.errorMessage)
        XCTAssertNil(LoadState.loading.errorMessage)
        XCTAssertNil(LoadState.loaded.errorMessage)
    }

    func test_givenLoadingState_whenIsLoadingIsRead_thenItIsTrue() {
        XCTAssertTrue(LoadState.loading.isLoading)
        XCTAssertFalse(LoadState.idle.isLoading)
        XCTAssertFalse(LoadState.loaded.isLoading)
    }
}
