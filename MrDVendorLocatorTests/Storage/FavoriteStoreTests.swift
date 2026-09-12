import XCTest
@testable import MrDVendorLocator

final class FavoriteStoreTests: XCTestCase {

    func test_givenEmptyInMemoryStore_whenIDsAreRead_thenSetIsEmpty() {
        // Given
        let store = InMemoryFavoriteStore()

        // When / Then
        XCTAssertTrue(store.ids().isEmpty)
    }

    func test_givenInMemoryStore_whenIDsAreSaved_thenTheyRoundTrip() {
        // Given
        let store = InMemoryFavoriteStore(["ven-001"])

        // When
        store.save(["ven-001", "ven-002"])

        // Then
        XCTAssertEqual(store.ids(), ["ven-001", "ven-002"])
    }

    func test_givenIsolatedUserDefaults_whenFavoritesAreSaved_thenTheySurviveANewStoreInstance() {
        // Given
        let suiteName = "favorite-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = UserDefaultsFavoriteStore(key: "favoriteVendorIDs", defaults: defaults)

        // When
        store.save(["ven-002"])
        let reloaded = UserDefaultsFavoriteStore(key: "favoriteVendorIDs", defaults: defaults)

        // Then
        XCTAssertEqual(reloaded.ids(), ["ven-002"])
        defaults.removePersistentDomain(forName: suiteName)
    }

    func test_givenUserDefaultsWithoutKey_whenIDsAreRead_thenSetIsEmpty() {
        // Given
        let suiteName = "favorite-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let store = UserDefaultsFavoriteStore(defaults: defaults)

        // When / Then
        XCTAssertTrue(store.ids().isEmpty)
        defaults.removePersistentDomain(forName: suiteName)
    }
}
