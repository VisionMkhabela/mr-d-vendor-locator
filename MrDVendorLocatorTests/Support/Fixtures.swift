import Foundation
@testable import MrDVendorLocator

enum Fixtures {
    static let capeTownDTO = VendorDTO(
        id: "ven-001",
        name: "Mr D Pizza — Cape Town CBD",
        address: "12 Loop St, Cape Town, 8000",
        coordinate: CoordinateDTO(lat: -33.918861, lng: 18.423300),
        isFavorite: false,
        updatedAt: "2025-06-01T12:00:00Z"
    )

    static let woodstockDTO = VendorDTO(
        id: "ven-008",
        name: "Mr D Express — Woodstock Kitchen",
        address: "66 Albert Rd, Woodstock, Cape Town, 7925",
        coordinate: nil,
        isFavorite: false,
        updatedAt: "2025-06-08T13:00:00Z"
    )

    static let kloofPlace = PlaceResult(
        id: "place-kloof",
        name: "Mr D Coffee — Kloof Street",
        address: "101 Kloof St, Gardens, Cape Town, 8001",
        coordinate: Coordinate(latitude: -33.927900, longitude: 18.412200)
    )

    static let vendorsJSON = """
    {
      "vendors": [
        {
          "id": "ven-001",
          "name": "Mr D Pizza — Cape Town CBD",
          "address": "12 Loop St, Cape Town, 8000",
          "coordinate": { "lat": -33.918861, "lng": 18.423300 },
          "isFavorite": false,
          "updatedAt": "2025-06-01T12:00:00Z"
        },
        {
          "id": "ven-008",
          "name": "Mr D Express — Woodstock Kitchen",
          "address": "66 Albert Rd, Woodstock, Cape Town, 7925",
          "isFavorite": false,
          "updatedAt": "2025-06-08T13:00:00Z"
        }
      ]
    }
    """

    static let sessionJSON = """
    {
      "token": "mrD_token_example_123",
      "issuedAt": "2025-06-01T12:00:00Z",
      "expiresIn": 3600
    }
    """
}
