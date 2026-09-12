import Foundation

enum AppConfig {
    /// Replace with a key from Google Cloud Console (Maps SDK for iOS + Places API).
    static let googleMapsAPIKey = "AIzaSyAVsoOCIZXd85zUl5-twnI2-N7QL4FoWVo"

    static var isGoogleAPIKeyConfigured: Bool {
        let key = googleMapsAPIKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return !key.isEmpty && key != "YOUR_GOOGLE_MAPS_API_KEY"
    }
}
