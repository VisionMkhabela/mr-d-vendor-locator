import Foundation
import GooglePlaces

/// Live Google Places integration. Swap in via `PlacesServiceFactory` when an API key is set.
final class GooglePlacesSearchService: PlacesSearching, @unchecked Sendable {
    private let client: GMSPlacesClient

    init(client: GMSPlacesClient = .shared()) {
        self.client = client
    }

    func search(query: String) async throws -> [PlaceResult] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let suggestions = try await autocomplete(query: trimmed)
        var places: [PlaceResult] = []

        for suggestion in suggestions.prefix(5) {
            if let place = try await details(for: suggestion) {
                places.append(place)
            }
        }

        return places
    }

    private func autocomplete(query: String) async throws -> [PlaceSuggestion] {
        try await withCheckedThrowingContinuation { continuation in
            let request = GMSAutocompleteRequest(query: query)
            let filter = GMSAutocompleteFilter()
            filter.countries = ["ZA"]
            request.filter = filter

            client.fetchAutocompleteSuggestions(from: request) { results, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let suggestions = (results ?? []).compactMap { result -> PlaceSuggestion? in
                    guard let suggestion = result.placeSuggestion else { return nil }
                    return PlaceSuggestion(
                        placeID: suggestion.placeID,
                        name: suggestion.attributedPrimaryText.string,
                        address: suggestion.attributedSecondaryText?.string ?? suggestion.attributedFullText.string
                    )
                }
                continuation.resume(returning: suggestions)
            }
        }
    }

    private func details(for suggestion: PlaceSuggestion) async throws -> PlaceResult? {
        try await withCheckedThrowingContinuation { continuation in
            let properties: [String] = [
                GMSPlaceProperty.name.rawValue,
                GMSPlaceProperty.placeID.rawValue,
                GMSPlaceProperty.coordinate.rawValue,
                GMSPlaceProperty.formattedAddress.rawValue
            ]
            let request = GMSFetchPlaceRequest(
                placeID: suggestion.placeID,
                placeProperties: properties,
                sessionToken: nil
            )

            client.fetchPlace(with: request) { place, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let place, let name = place.name else {
                    continuation.resume(returning: nil)
                    return
                }

                let result = PlaceResult(
                    id: place.placeID ?? suggestion.placeID,
                    name: name,
                    address: place.formattedAddress ?? suggestion.address,
                    coordinate: Coordinate(
                        latitude: place.coordinate.latitude,
                        longitude: place.coordinate.longitude
                    )
                )
                continuation.resume(returning: result)
            }
        }
    }
}

private struct PlaceSuggestion {
    let placeID: String
    let name: String
    let address: String
}
