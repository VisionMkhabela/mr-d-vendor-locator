import Security
import XCTest
@testable import MrDVendorLocator

final class KeychainTokenStoreTests: XCTestCase {
    private var store: KeychainTokenStore?

    override func setUpWithError() throws {
        let candidate = KeychainTokenStore(
            service: "com.offerzen.MrDVendorLocator.tests",
            account: "session-token-\(UUID().uuidString)"
        )

        do {
            try candidate.clear()
        } catch KeychainError.unexpectedStatus(let status) where status == errSecMissingEntitlement {
            throw XCTSkip("Keychain needs a signed host app; skipped in unsigned xcodebuild.")
        }

        store = candidate
    }

    override func tearDownWithError() throws {
        try store?.clear()
        store = nil
    }

    func test_givenNoItem_whenRead_thenTokenIsNil() throws {
        // Given
        let store = try XCTUnwrap(store)

        // When
        let token = try store.read()

        // Then
        XCTAssertNil(token)
    }

    func test_givenSavedToken_whenRead_thenSameValueIsReturned() throws {
        // Given
        let store = try XCTUnwrap(store)
        try store.save("mrD_token_example_123")

        // When
        let token = try store.read()

        // Then
        XCTAssertEqual(token, "mrD_token_example_123")
    }

    func test_givenExistingToken_whenSavedAgain_thenItIsReplaced() throws {
        // Given
        let store = try XCTUnwrap(store)
        try store.save("old-token")

        // When
        try store.save("new-token")

        // Then
        XCTAssertEqual(try store.read(), "new-token")
    }

    func test_givenSavedToken_whenCleared_thenReadReturnsNil() throws {
        // Given
        let store = try XCTUnwrap(store)
        try store.save("mrD_token_example_123")

        // When
        try store.clear()

        // Then
        XCTAssertNil(try store.read())
    }

    func test_givenClearOnEmptyStore_whenCalled_thenItDoesNotThrow() throws {
        let store = try XCTUnwrap(store)
        XCTAssertNoThrow(try store.clear())
    }
}

final class KeychainErrorTests: XCTestCase {

    func test_givenUnexpectedStatus_whenLocalizedDescriptionIsRead_thenStatusIsIncluded() {
        XCTAssertEqual(
            KeychainError.unexpectedStatus(-34018).localizedDescription,
            "Keychain failed with status -34018."
        )
    }

    func test_givenInvalidData_whenLocalizedDescriptionIsRead_thenCopyExplainsTheFailure() {
        XCTAssertEqual(
            KeychainError.invalidData.localizedDescription,
            "The stored token could not be read."
        )
    }
}
