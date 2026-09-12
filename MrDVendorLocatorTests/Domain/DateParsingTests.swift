import XCTest
@testable import MrDVendorLocator

final class DateParsingTests: XCTestCase {

    func test_givenInternetDateTime_whenParsed_thenDateMatchesUTCComponents() throws {
        // Given
        let value = "2025-06-01T12:00:00Z"

        // When
        let date = DateParsing.iso8601(value)

        // Then
        let parsed = try XCTUnwrap(date)
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: parsed)
        XCTAssertEqual(components.year, 2025)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 1)
        XCTAssertEqual(components.hour, 12)
    }

    func test_givenFractionalSeconds_whenParsed_thenDateIsAccepted() {
        // Given
        let value = "2025-06-01T12:00:00.250Z"

        // When
        let date = DateParsing.iso8601(value)

        // Then
        XCTAssertNotNil(date)
    }

    func test_givenInvalidDateString_whenParsed_thenResultIsNil() {
        // Given
        let value = "not-a-date"

        // When / Then
        XCTAssertNil(DateParsing.iso8601(value))
    }
}
