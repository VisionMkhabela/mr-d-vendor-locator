import Foundation
import Observation

@MainActor
@Observable
final class PlaceSearchViewModel {
    var query = ""
    private(set) var results: [PlaceResult] = []
    private(set) var state: LoadState = .idle

    @ObservationIgnored
    private let places: PlacesSearching

    init(places: PlacesSearching) {
        self.places = places
    }

    func search() async {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            results = []
            state = .idle
            return
        }

        state = .loading
        do {
            results = try await places.search(query: trimmed)
            state = .loaded
        } catch {
            results = []
            state = .failed(error.localizedDescription)
        }
    }
}
