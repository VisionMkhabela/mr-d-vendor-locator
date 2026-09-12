import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    var draftToken = ""
    private(set) var storedToken: String?
    private(set) var statusMessage: String?
    private(set) var isWorking = false

    @ObservationIgnored
    private let tokenStore: TokenStoring
    @ObservationIgnored
    private let service: VendorServing

    var hasStoredToken: Bool {
        storedToken?.isEmpty == false
    }

    init(tokenStore: TokenStoring, service: VendorServing) {
        self.tokenStore = tokenStore
        self.service = service
    }

    func refresh() {
        do {
            storedToken = try tokenStore.read()
            draftToken = storedToken ?? ""
            statusMessage = nil
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func save() {
        let token = draftToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else {
            statusMessage = "Enter a token before saving."
            return
        }

        do {
            try tokenStore.save(token)
            storedToken = token
            statusMessage = "Token saved to Keychain. It is sent as a Bearer token on API calls."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func clear() {
        do {
            try tokenStore.clear()
            storedToken = nil
            draftToken = ""
            statusMessage = "Token cleared from Keychain."
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    func loadDemoToken() async {
        isWorking = true
        defer { isWorking = false }

        do {
            let token = try await service.fetchSessionToken()
            try tokenStore.save(token)
            storedToken = token
            draftToken = token
            statusMessage = "Demo token loaded from /v1/session and stored in Keychain."
        } catch {
            statusMessage = error.localizedDescription
        }
    }
}
