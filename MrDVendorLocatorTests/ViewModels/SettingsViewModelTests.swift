import XCTest
@testable import MrDVendorLocator

@MainActor
final class SettingsViewModelTests: XCTestCase {

    func test_givenStoredToken_whenRefreshed_thenDraftMatchesKeychainAndStatusClears() {
        // Given
        let store = InMemoryTokenStore(token: "saved-token")
        let viewModel = SettingsViewModel(tokenStore: store, service: StubVendorService())

        // When
        viewModel.refresh()

        // Then
        XCTAssertEqual(viewModel.storedToken, "saved-token")
        XCTAssertEqual(viewModel.draftToken, "saved-token")
        XCTAssertTrue(viewModel.hasStoredToken)
        XCTAssertNil(viewModel.statusMessage)
    }

    func test_givenTokenStoreFailure_whenRefreshed_thenErrorCopyIsShown() {
        // Given
        let store = InMemoryTokenStore()
        store.error = KeychainError.invalidData
        let viewModel = SettingsViewModel(tokenStore: store, service: StubVendorService())

        // When
        viewModel.refresh()

        // Then
        XCTAssertEqual(viewModel.statusMessage, KeychainError.invalidData.localizedDescription)
    }

    func test_givenEmptyDraft_whenSaveTapped_thenStoreIsUnchangedAndUserIsPrompted() {
        // Given
        let store = InMemoryTokenStore()
        let viewModel = SettingsViewModel(tokenStore: store, service: StubVendorService())
        viewModel.draftToken = "   "

        // When
        viewModel.save()

        // Then
        XCTAssertNil(store.token)
        XCTAssertFalse(viewModel.hasStoredToken)
        XCTAssertEqual(viewModel.statusMessage, "Enter a token before saving.")
    }

    func test_givenDraftToken_whenSaved_thenTrimmedValueIsStored() {
        // Given
        let store = InMemoryTokenStore()
        let viewModel = SettingsViewModel(tokenStore: store, service: StubVendorService())
        viewModel.draftToken = "  mrD_token_example_123  "

        // When
        viewModel.save()

        // Then
        XCTAssertEqual(store.token, "mrD_token_example_123")
        XCTAssertEqual(viewModel.storedToken, "mrD_token_example_123")
        XCTAssertTrue(viewModel.hasStoredToken)
        XCTAssertEqual(
            viewModel.statusMessage,
            "Token saved to Keychain. It is sent as a Bearer token on API calls."
        )
    }

    func test_givenSaveFailure_whenSaveTapped_thenErrorCopyIsShown() {
        // Given
        let store = InMemoryTokenStore()
        store.error = KeychainError.unexpectedStatus(1)
        let viewModel = SettingsViewModel(tokenStore: store, service: StubVendorService())
        viewModel.draftToken = "token"

        // When
        viewModel.save()

        // Then
        XCTAssertEqual(viewModel.statusMessage, KeychainError.unexpectedStatus(1).localizedDescription)
        XCTAssertNil(viewModel.storedToken)
    }

    func test_givenStoredToken_whenCleared_thenDraftAndStoreAreEmpty() {
        // Given
        let store = InMemoryTokenStore(token: "saved-token")
        let viewModel = SettingsViewModel(tokenStore: store, service: StubVendorService())
        viewModel.refresh()

        // When
        viewModel.clear()

        // Then
        XCTAssertNil(store.token)
        XCTAssertNil(viewModel.storedToken)
        XCTAssertEqual(viewModel.draftToken, "")
        XCTAssertFalse(viewModel.hasStoredToken)
        XCTAssertEqual(viewModel.statusMessage, "Token cleared from Keychain.")
    }

    func test_givenSessionEndpoint_whenDemoTokenLoads_thenItIsSavedToTheStore() async {
        // Given
        let store = InMemoryTokenStore()
        let service = StubVendorService(token: "mrD_token_example_123")
        let viewModel = SettingsViewModel(tokenStore: store, service: service)

        // When
        await viewModel.loadDemoToken()

        // Then
        XCTAssertEqual(service.fetchSessionCallCount, 1)
        XCTAssertEqual(store.token, "mrD_token_example_123")
        XCTAssertEqual(viewModel.draftToken, "mrD_token_example_123")
        XCTAssertFalse(viewModel.isWorking)
        XCTAssertEqual(
            viewModel.statusMessage,
            "Demo token loaded from /v1/session and stored in Keychain."
        )
    }

    func test_givenSessionEndpointFailure_whenDemoTokenLoads_thenErrorIsShownAndWorkCompletes() async {
        // Given
        let store = InMemoryTokenStore()
        let service = StubVendorService(error: APIError.unavailable)
        let viewModel = SettingsViewModel(tokenStore: store, service: service)

        // When
        await viewModel.loadDemoToken()

        // Then
        XCTAssertNil(store.token)
        XCTAssertFalse(viewModel.isWorking)
        XCTAssertEqual(viewModel.statusMessage, APIError.unavailable.localizedDescription)
    }

    func test_givenNoStoredToken_whenHasStoredTokenIsRead_thenItIsFalse() {
        // Given
        let viewModel = SettingsViewModel(tokenStore: InMemoryTokenStore(), service: StubVendorService())

        // When / Then
        XCTAssertFalse(viewModel.hasStoredToken)
    }
}
