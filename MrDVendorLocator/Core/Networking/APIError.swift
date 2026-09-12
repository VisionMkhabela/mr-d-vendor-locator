import Foundation

enum APIError: Error, Equatable, LocalizedError {
    case invalidResponse
    case notFound
    case decodingFailed
    case unauthorized
    case unavailable

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .notFound:
            return "We couldn't find that resource."
        case .decodingFailed:
            return "We couldn't read the vendor data."
        case .unauthorized:
            return "Your session token was rejected. Add a valid token in Settings."
        case .unavailable:
            return "The service is temporarily unavailable. Please try again."
        }
    }
}
