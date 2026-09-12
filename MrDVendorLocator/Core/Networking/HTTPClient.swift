import Foundation

protocol HTTPClient: Sendable {
    func send(_ request: HTTPRequest) async throws -> Data
}
