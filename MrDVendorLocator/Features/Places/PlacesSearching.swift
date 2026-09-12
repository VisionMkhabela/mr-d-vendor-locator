import Foundation

protocol PlacesSearching: Sendable {
    func search(query: String) async throws -> [PlaceResult]
}

struct PlaceResult: Identifiable, Equatable {
    let id: String
    let name: String
    let address: String
    let coordinate: Coordinate
}

enum PlacesServiceFactory {
    static func make(isLive: Bool = AppConfig.isGoogleAPIKeyConfigured) -> PlacesSearching {
        isLive ? GooglePlacesSearchService() : MockPlacesSearchService()
    }
}
