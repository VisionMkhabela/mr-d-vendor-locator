import Foundation

struct MockPlacesSearchService: PlacesSearching {
    private let catalog: [PlaceResult]

    init(catalog: [PlaceResult] = PlaceResult.southAfricaSamples) {
        self.catalog = catalog
    }

    func search(query: String) async throws -> [PlaceResult] {
        try await Task.sleep(nanoseconds: 280_000_000)

        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return catalog }

        return catalog.filter { place in
            place.name.localizedCaseInsensitiveContains(trimmed)
                || place.address.localizedCaseInsensitiveContains(trimmed)
        }
    }
}

extension PlaceResult {
    static let southAfricaSamples: [PlaceResult] = [
        PlaceResult(
            id: "place-kloof",
            name: "Mr D Coffee — Kloof Street",
            address: "101 Kloof St, Gardens, Cape Town, 8001",
            coordinate: Coordinate(latitude: -33.927900, longitude: 18.412200)
        ),
        PlaceResult(
            id: "place-obs",
            name: "Mr D Noodles — Observatory",
            address: "180 Lower Main Rd, Observatory, Cape Town, 7925",
            coordinate: Coordinate(latitude: -33.937800, longitude: 18.472900)
        ),
        PlaceResult(
            id: "place-rosebank",
            name: "Mr D Pizza — Rosebank",
            address: "50 Bath Ave, Rosebank, Johannesburg, 2196",
            coordinate: Coordinate(latitude: -26.145000, longitude: 28.041600)
        ),
        PlaceResult(
            id: "place-umhlanga",
            name: "Mr D Grill — Umhlanga",
            address: "14 Chartwell Dr, Umhlanga Rocks, 4319",
            coordinate: Coordinate(latitude: -29.725500, longitude: 31.085000)
        )
    ]
}
