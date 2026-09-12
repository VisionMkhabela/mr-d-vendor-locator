import XCTest
@testable import MrDVendorLocator

@MainActor
final class PlaceSearchViewModelTests: XCTestCase {

    func test_givenBlankQuery_whenSearchRuns_thenStateReturnsToIdleWithoutCallingResults() async {
        // Given
        let places = StubPlacesSearchService(results: [Fixtures.kloofPlace])
        let viewModel = PlaceSearchViewModel(places: places)
        viewModel.query = "   "

        // When
        await viewModel.search()

        // Then
        XCTAssertEqual(viewModel.state, .idle)
        XCTAssertTrue(viewModel.results.isEmpty)
    }

    func test_givenMatchingQuery_whenSearchSucceeds_thenResultsArePublished() async {
        // Given
        let places = StubPlacesSearchService(results: [Fixtures.kloofPlace])
        let viewModel = PlaceSearchViewModel(places: places)
        viewModel.query = "Kloof"

        // When
        await viewModel.search()

        // Then
        XCTAssertEqual(viewModel.state, .loaded)
        XCTAssertEqual(viewModel.results, [Fixtures.kloofPlace])
    }

    func test_givenPlacesFailure_whenSearchRuns_thenFailedStateClearsPreviousResults() async {
        // Given
        let places = StubPlacesSearchService(error: APIError.unavailable)
        let viewModel = PlaceSearchViewModel(places: places)
        viewModel.query = "Cape Town"

        // When
        await viewModel.search()

        // Then
        XCTAssertTrue(viewModel.results.isEmpty)
        XCTAssertEqual(viewModel.state, .failed(APIError.unavailable.localizedDescription))
    }
}
