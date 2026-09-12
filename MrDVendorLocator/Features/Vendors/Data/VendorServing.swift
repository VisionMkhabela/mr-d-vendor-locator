import Foundation

protocol VendorServing: Sendable {
    func fetchVendors() async throws -> [VendorDTO]
    func fetchSessionToken() async throws -> String
}
