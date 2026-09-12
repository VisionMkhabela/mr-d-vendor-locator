import Foundation

/// Simulates REST over JSON by serving bundled payloads with a short delay.
final class LocalJSONHTTPClient: HTTPClient, @unchecked Sendable {
    private let bundle: Bundle
    private let delayNanoseconds: UInt64
    private let jsonFolder: String?

    init(
        bundle: Bundle = .main,
        delayNanoseconds: UInt64 = 350_000_000,
        jsonFolder: String? = "MockAPI"
    ) {
        self.bundle = bundle
        self.delayNanoseconds = delayNanoseconds
        self.jsonFolder = jsonFolder
    }

    func send(_ request: HTTPRequest) async throws -> Data {
        try await Task.sleep(nanoseconds: delayNanoseconds)

        let fileName: String
        switch (request.method, request.path) {
        case (.get, "/v1/vendors"):
            fileName = "vendors"
        case (.get, "/v1/session"):
            fileName = "session"
        default:
            throw APIError.notFound
        }

        guard let url = resourceURL(named: fileName) else {
            throw APIError.notFound
        }

        do {
            return try Data(contentsOf: url)
        } catch {
            throw APIError.unavailable
        }
    }

    private func resourceURL(named name: String) -> URL? {
        if let jsonFolder,
           let url = bundle.url(forResource: name, withExtension: "json", subdirectory: jsonFolder) {
            return url
        }
        return bundle.url(forResource: name, withExtension: "json")
    }
}
