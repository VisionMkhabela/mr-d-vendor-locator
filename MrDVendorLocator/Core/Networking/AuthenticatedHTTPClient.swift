import Foundation

/// Decorator that attaches the Keychain session token to outgoing requests.
struct AuthenticatedHTTPClient: HTTPClient {
    private let client: HTTPClient
    private let tokenStore: TokenStoring

    init(client: HTTPClient, tokenStore: TokenStoring) {
        self.client = client
        self.tokenStore = tokenStore
    }

    func send(_ request: HTTPRequest) async throws -> Data {
        var authenticated = request
        if let token = try tokenStore.read(), !token.isEmpty {
            authenticated.headers["Authorization"] = "Bearer \(token)"
        }
        return try await client.send(authenticated)
    }
}
