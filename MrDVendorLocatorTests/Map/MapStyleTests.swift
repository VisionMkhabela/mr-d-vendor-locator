import SwiftUI
import XCTest
@testable import MrDVendorLocator

final class MapStyleTests: XCTestCase {

    func test_givenLightColorScheme_whenStyleJSONIsRequested_thenDefaultGoogleStyleIsUsed() {
        // Given / When
        let json = MapStyle.json(for: .light)

        // Then
        XCTAssertNil(json)
    }

    func test_givenDarkColorScheme_whenStyleJSONIsRequested_thenNightStyleJSONIsReturned() throws {
        // Given / When
        let json = try XCTUnwrap(MapStyle.json(for: .dark))

        // Then
        XCTAssertTrue(json.contains("\"featureType\":\"water\""))
        XCTAssertTrue(json.contains("#17263c"))
    }
}
