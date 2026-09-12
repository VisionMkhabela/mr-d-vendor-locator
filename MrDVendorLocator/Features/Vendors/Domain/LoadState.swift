import Foundation

enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case failed(String)

    var errorMessage: String? {
        if case .failed(let message) = self {
            return message
        }
        return nil
    }

    var isLoading: Bool {
        self == .loading
    }
}
