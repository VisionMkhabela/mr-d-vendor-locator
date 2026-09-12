# Solution

Senior-shaped slice of a vendor locator: SwiftUI, async/await, Google Maps + Places, Keychain. Built to be easy to follow in a review, not to showcase every pattern at once.

## Architecture

```
AppFactory (composition root)
        │
        ├── AppCoordinator          navigation (tabs, selected vendor, sheets)
        ├── VendorListViewModel     vendor state for list + map
        ├── PlaceSearchViewModel    Places enhancement
        └── SettingsViewModel       Keychain token
                │
        VendorService ── AuthenticatedHTTPClient ── LocalJSONHTTPClient
                │                                        └── vendors.json / session.json
        PlacesSearching ── GooglePlacesSearchService or MockPlacesSearchService
        TokenStoring    ── KeychainTokenStore
```

**MVVM + Coordinator.** Views are dumb. `@Observable` view models own screen state and async work. The coordinator owns *where* the user goes (tab, selected pin, place-search sheet). List and map share one `VendorListViewModel`, so favorites and newly added places stay in sync. SwiftUI tracks property access automatically — no `ObservableObject`, `@Published`, or Combine.

**Dependency injection.** `AppFactory` is the only place that knows concrete types. Features depend on `HTTPClient`, `VendorServing`, `TokenStoring`, `FavoriteStoring`, `PlacesSearching`, and `VendorRouting`.

**SOLID, kept small.**

- *S* — one type, one job (`LocalJSONHTTPClient` only serves JSON; `VendorFactory` only maps DTOs).
- *O* — new HTTP sources or Places backends without changing ViewModels.
- *L* — mocks are drop-in stand-ins for the live services.
- *I* — `VendorRouting` is only the two navigation events the list needs.
- *D* — high-level modules depend on protocols.

**Value types first.** `Vendor`, `Coordinate`, `HTTPRequest`, `PlaceResult`, and DTOs are structs. Classes are reserved for shared mutable state (ViewModels, coordinator) and system wrappers (Keychain, Google clients).

**Patterns used on purpose.**

- *Factory* — `AppFactory`, `VendorFactory`, `PlacesServiceFactory`.
- *Builder* — `HTTPRequest.Builder` for readable request construction.
- *Decorator* — `AuthenticatedHTTPClient` adds the Bearer token without changing the JSON client.
- *Strategy* — live vs mock Places behind `PlacesSearching`.

## Task 1 — Vendor browsing

`GET /v1/vendors` is simulated by `LocalJSONHTTPClient` with a short delay so loading state is visible. JSON lives in `Resources/MockAPI/vendors.json`.

Favorites are local (`UserDefaultsFavoriteStore`) so toggling is instant and survives relaunch without pretending the mock API persists them. Reload uses `.refreshable` and `async/await`. Errors map to user-facing copy via `APIError`.

Light/dark: semantic SwiftUI colors (`primary`, `secondary`, grouped backgrounds) plus a Google Maps night style applied from `@Environment(\.colorScheme)` while the app is running.

## Task 2 — Map + Places

`GoogleMapView` is a `UIViewRepresentable` over **Google Maps SDK for iOS** (SPM: `https://github.com/googlemaps/ios-maps-sdk`). Markers come from the current vendor list. Selecting a row sets `AppCoordinator.selectedVendorID` and switches to the Map tab; the map then animates to that pin. Tapping a marker updates the card (light list ↔ map highlighting).

**Chosen enhancement: Place search.** Users search by name or address and add a result as a vendor with a marker. That is the more demo-visible of the two options, and it still exercises autocomplete + place details.

**Places SDK integration boundary**

```
PlaceSearchViewModel → PlacesSearching
                           ├── GooglePlacesSearchService   // GMSPlacesClient, live key
                           └── MockPlacesSearchService     // bundled Cape Town / Joburg / Durban samples
```

`PlacesServiceFactory` picks live vs mock from `AppConfig.isGoogleAPIKeyConfigured`.

Live path (`GooglePlacesSearchService`):

1. `GMSPlacesClient.provideAPIKey` in `GoogleServicesBootstrap`.
2. `GMSAutocompleteRequest` → `fetchAutocompleteSuggestions`.
3. `GMSFetchPlaceRequest` → `fetchPlace` for name, address, coordinates.
4. Callbacks wrapped in `async/await` so the rest of the app never sees Google’s completion handlers.

If a key is not ready, mock responses keep the same `PlaceResult` shape. Swap is one factory line; no ViewModel changes. Enable **Places API** and **Maps SDK for iOS** on the key, paste it into `AppConfig.swift`, rebuild.

Vendors without coordinates (Woodstock in the sample) stay on the list and are skipped on the map. Address-to-coordinates was the other allowed enhancement; it was left out on purpose so the delivery stays focused.

## Task 3 — Keychain + tests

`KeychainTokenStore` uses a generic password (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`). Settings can save, read, clear, or load a demo token from `GET /v1/session`.

`AuthenticatedHTTPClient` attaches `Authorization: Bearer <token>` when a token exists. The mock API does not require it (vendors are public in this slice); the header is still the production-shaped integration point.

**Focused unit test:** `VendorDecodingTests` — JSON decoding, optional coordinates, and `VendorFactory` favorite mapping. Extra: `VendorListViewModelTests` for load success, favorite persistence, and error state, using a stub service.

## Trade-offs

| Choice | Why |
| --- | --- |
| Bundled JSON instead of a local server | Fits the 4-hour window; still a real `HTTPClient` so a live `URLSession` client can replace it later. |
| One shared list ViewModel for list + map | Avoids duplicated vendor state. A dedicated map ViewModel would be cleaner if the map grew its own use cases. |
| Place search, not geocoding | Better demo. The Places protocol can host geocoding later. |
| Mock Places until a key exists | Assignment allows it; SDK types and call sites stay in the project. |
| UserDefaults for favorites, Keychain only for the token | Favorites are not secrets. |
| No Fastlane / clustering / offline cache | Bonus items. CI workflow is the only extra. |
| `@Observable` (iOS 17) instead of `ObservableObject` | Latest SwiftUI observation; finer-grained updates, no Combine. Assignment allows iOS 16+, this is a deliberate modernisation. |

## What I would do next

- `URLSessionHTTPClient` behind the same protocol, pointed at a real BFF.
- Address lookup for vendors missing coordinates, still through `PlacesSearching`.
- Marker clustering for denser cities.
- Snapshot tests for `VendorRow` / error states.
