import XCTest
@testable import MrDVendorLocator

@MainActor
final class AppCoordinatorTests: XCTestCase {

    func test_givenDefaultCoordinator_whenCreated_thenVendorsTabIsSelected() {
        // Given / When
        let coordinator = AppCoordinator()

        // Then
        XCTAssertEqual(coordinator.selectedTab, .vendors)
        XCTAssertNil(coordinator.selectedVendorID)
        XCTAssertFalse(coordinator.isPlaceSearchPresented)
    }

    func test_givenVendorID_whenShownOnMap_thenMapTabIsSelectedWithThatVendor() {
        // Given
        let coordinator = AppCoordinator()

        // When
        coordinator.showOnMap(vendorID: "ven-001")

        // Then
        XCTAssertEqual(coordinator.selectedVendorID, "ven-001")
        XCTAssertEqual(coordinator.selectedTab, .map)
    }

    func test_givenClosedSheet_whenPlaceSearchIsPresented_thenSheetFlagIsTrue() {
        // Given
        let coordinator = AppCoordinator()

        // When
        coordinator.presentPlaceSearch()

        // Then
        XCTAssertTrue(coordinator.isPlaceSearchPresented)
    }

    func test_givenOpenSheet_whenDismissed_thenSheetFlagIsFalse() {
        // Given
        let coordinator = AppCoordinator()
        coordinator.presentPlaceSearch()

        // When
        coordinator.dismissPlaceSearch()

        // Then
        XCTAssertFalse(coordinator.isPlaceSearchPresented)
    }

    func test_givenMapSelection_whenVendorIsSelected_thenOnlyTheIDChanges() {
        // Given
        let coordinator = AppCoordinator()
        coordinator.selectedTab = .map

        // When
        coordinator.selectVendor("ven-002")

        // Then
        XCTAssertEqual(coordinator.selectedVendorID, "ven-002")
        XCTAssertEqual(coordinator.selectedTab, .map)
    }
}
