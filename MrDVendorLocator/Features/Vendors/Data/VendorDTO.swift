import Foundation

struct VendorsResponseDTO: Decodable, Equatable {
    let vendors: [VendorDTO]
}

struct VendorDTO: Decodable, Equatable {
    let id: String
    let name: String
    let address: String
    let coordinate: CoordinateDTO?
    let isFavorite: Bool?
    let updatedAt: String
}

struct CoordinateDTO: Decodable, Equatable {
    let lat: Double
    let lng: Double
}

struct SessionResponseDTO: Decodable, Equatable {
    let token: String
    let issuedAt: String?
    let expiresIn: Int?
}
