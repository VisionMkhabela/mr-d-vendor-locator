import Foundation

struct Vendor: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let address: String
    let coordinate: Coordinate?
    var isFavorite: Bool
    let updatedAt: Date

    var hasCoordinate: Bool {
        coordinate != nil
    }
}

extension Vendor {
    static let sample = Vendor(
        id: "ven-001",
        name: "Mr D Pizza — Cape Town CBD",
        address: "12 Loop St, Cape Town, 8000",
        coordinate: Coordinate(latitude: -33.918861, longitude: 18.423300),
        isFavorite: false,
        updatedAt: Date(timeIntervalSince1970: 1_748_779_200)
    )
}
