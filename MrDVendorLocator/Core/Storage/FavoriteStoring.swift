import Foundation

protocol FavoriteStoring: AnyObject {
    func ids() -> Set<String>
    func save(_ ids: Set<String>)
}

final class UserDefaultsFavoriteStore: FavoriteStoring {
    private let key: String
    private let defaults: UserDefaults

    init(key: String = "favoriteVendorIDs", defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    func ids() -> Set<String> {
        Set(defaults.stringArray(forKey: key) ?? [])
    }

    func save(_ ids: Set<String>) {
        defaults.set(Array(ids), forKey: key)
    }
}

final class InMemoryFavoriteStore: FavoriteStoring {
    private var stored: Set<String>

    init(_ ids: Set<String> = []) {
        stored = ids
    }

    func ids() -> Set<String> {
        stored
    }

    func save(_ ids: Set<String>) {
        stored = ids
    }
}
