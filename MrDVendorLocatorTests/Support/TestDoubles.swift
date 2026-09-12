import Foundation
@testable import MrDVendorLocator

final class CapturingHTTPClient: HTTPClient, @unchecked Sendable {
    var lastRequest: HTTPRequest?
    var result: Result<Data, Error> = .success(Data())
    var sendCount = 0

    func send(_ request: HTTPRequest) async throws -> Data {
        sendCount += 1
        lastRequest = request
        return try result.get()
    }
}

final class InMemoryTokenStore: TokenStoring, @unchecked Sendable {
    var token: String?
    var error: Error?

    init(token: String? = nil) {
        self.token = token
    }

    func save(_ token: String) throws {
        if let error { throw error }
        self.token = token
    }

    func read() throws -> String? {
        if let error { throw error }
        return token
    }

    func clear() throws {
        if let error { throw error }
        token = nil
    }
}

final class StubVendorService: VendorServing, @unchecked Sendable {
    var dtos: [VendorDTO]
    var error: Error?
    var token: String
    var fetchVendorsCallCount = 0
    var fetchSessionCallCount = 0

    init(dtos: [VendorDTO] = [], error: Error? = nil, token: String = "mrD_token_example_123") {
        self.dtos = dtos
        self.error = error
        self.token = token
    }

    func fetchVendors() async throws -> [VendorDTO] {
        fetchVendorsCallCount += 1
        if let error { throw error }
        return dtos
    }

    func fetchSessionToken() async throws -> String {
        fetchSessionCallCount += 1
        if let error { throw error }
        return token
    }
}

struct StubPlacesSearchService: PlacesSearching {
    var results: [PlaceResult]
    var error: Error?

    init(results: [PlaceResult] = [], error: Error? = nil) {
        self.results = results
        self.error = error
    }

    func search(query: String) async throws -> [PlaceResult] {
        if let error { throw error }
        return results
    }
}

@MainActor
final class SpyVendorRouter: VendorRouting {
    var shownVendorID: Vendor.ID?
    var didPresentPlaceSearch = false

    func showOnMap(vendorID: Vendor.ID) {
        shownVendorID = vendorID
    }

    func presentPlaceSearch() {
        didPresentPlaceSearch = true
    }
}
