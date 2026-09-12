import Foundation

struct VendorService: VendorServing {
    private let client: HTTPClient
    private let decoder: JSONDecoder

    init(client: HTTPClient, decoder: JSONDecoder = JSONDecoder()) {
        self.client = client
        self.decoder = decoder
    }

    func fetchVendors() async throws -> [VendorDTO] {
        let data = try await client.send(.vendors)
        do {
            return try decoder.decode(VendorsResponseDTO.self, from: data).vendors
        } catch {
            throw APIError.decodingFailed
        }
    }

    func fetchSessionToken() async throws -> String {
        let data = try await client.send(.session)
        do {
            return try decoder.decode(SessionResponseDTO.self, from: data).token
        } catch {
            throw APIError.decodingFailed
        }
    }
}
