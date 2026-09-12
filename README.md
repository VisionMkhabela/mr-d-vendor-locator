# Mr D Vendor Locator

SwiftUI take-home: discover nearby vendors, plot them on Google Maps, and store a session token in the Keychain.

## Requirements

- Xcode 15 or later
- iOS 17+ simulator or device
- A Google Maps Platform API key with **Maps SDK for iOS** and **Places API** enabled (optional for first run; Places is mocked until a key is set)

## Run locally

1. Open `MrDVendorLocator.xcodeproj` in Xcode.
2. Paste your Google API key into `MrDVendorLocator/App/AppConfig.swift`:

```swift
static let googleMapsAPIKey = "YOUR_REAL_KEY"
```

3. Select an iPhone simulator and press **Run**.

Without a key the app still launches. Vendors load from bundled JSON, the Google Maps view is present, and Place search uses a mock that keeps the same `PlacesSearching` boundary as the live SDK.

### Enable live Google services

In [Google Cloud Console](https://console.cloud.google.com/):

1. Create a project and enable billing.
2. Enable **Maps SDK for iOS** and **Places API** (New or legacy).
3. Create an iOS API key and restrict it to `com.offerzen.MrDVendorLocator`.
4. Put the key in `AppConfig.swift` and rebuild.

`AppFactory` then wires `GooglePlacesSearchService` instead of `MockPlacesSearchService`.

## What to try in the app

- **Vendors**: list with name, address, favorite heart, pull-to-refresh, loading and error states.
- Tap a vendor to jump to the **Map** tab and zoom to its marker.
- **+** or the map search icon: Places search. Add a result as a new vendor with a marker.
- Toggle **light/dark mode** in Control Center; list colors and the map style update live.
- **Settings**: save / read / clear a token in Keychain, or load the demo token from `GET /v1/session`. The token is sent as `Authorization: Bearer` on mock API calls.

One vendor (`Mr D Express — Woodstock Kitchen`) has no coordinates on purpose, so it appears in the list but not on the map.

## Tests

```bash
xcodebuild test -scheme MrDVendorLocator -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.1'
```

Or **Product → Test** in Xcode. The focused tests cover vendor JSON decoding, list/settings/search ViewModels, networking, Keychain, and Places.

## Architecture

Composition root (`AppFactory`) injects protocols into MVVM screens. `AppCoordinator` owns tabs, selected vendor, and the place-search sheet. Networking is a tiny REST client backed by bundled JSON. Details and trade-offs are in [SOLUTION.md](SOLUTION.md).

## Loom demo script (5–10 min)

1. Launch, show vendor list loading from JSON, favorite toggle, pull to refresh.
2. Switch to dark mode, then back.
3. Tap a vendor → map recenters; tap a marker → card updates.
4. Search “Kloof”, add a place, show the new marker.
5. Settings: load demo token, show Keychain save/clear.
6. Xcode: walk `AppFactory` → coordinator → `VendorListViewModel` → `LocalJSONHTTPClient` → `KeychainTokenStore` → `PlacesSearching`.
7. Run the unit tests. Mention Places mock vs live key.
