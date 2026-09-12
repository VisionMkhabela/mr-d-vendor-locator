import Foundation

enum VendorFactory {
    static func make(from dto: VendorDTO, favoriteIDs: Set<String>) -> Vendor {
        Vendor(
            id: dto.id,
            name: dto.name,
            address: dto.address,
            coordinate: dto.coordinate.map { Coordinate(latitude: $0.lat, longitude: $0.lng) },
            isFavorite: favoriteIDs.contains(dto.id) || (dto.isFavorite ?? false),
            updatedAt: DateParsing.iso8601(dto.updatedAt) ?? .now
        )
    }

    static func make(from place: PlaceResult) -> Vendor {
        Vendor(
            id: "ven-\(UUID().uuidString)",
            name: place.name,
            address: place.address,
            coordinate: place.coordinate,
            isFavorite: false,
            updatedAt: .now
        )
    }
}

enum DateParsing {
    static func iso8601(_ value: String) -> Date? {
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFractional.date(from: value) {
            return date
        }

        let basic = ISO8601DateFormatter()
        basic.formatOptions = [.withInternetDateTime]
        return basic.date(from: value)
    }
}
