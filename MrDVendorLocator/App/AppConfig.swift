import Foundation

enum AppConfig {
    static var googleMapsAPIKey: String {
        Secrets.googleMapsAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var isGoogleAPIKeyConfigured: Bool {
        !googleMapsAPIKey.isEmpty && googleMapsAPIKey != "YOUR_GOOGLE_MAPS_API_KEY"
    }
}
