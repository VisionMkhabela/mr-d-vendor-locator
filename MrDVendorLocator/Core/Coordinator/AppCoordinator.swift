import Foundation
import Observation

@MainActor
protocol VendorRouting: AnyObject {
    func showOnMap(vendorID: Vendor.ID)
    func presentPlaceSearch()
}

@MainActor
@Observable
final class AppCoordinator: VendorRouting {
    enum Tab: Hashable {
        case vendors
        case map
        case settings
    }

    var selectedTab: Tab = .vendors
    var selectedVendorID: Vendor.ID?
    var isPlaceSearchPresented = false

    func showOnMap(vendorID: Vendor.ID) {
        selectedVendorID = vendorID
        selectedTab = .map
    }

    func presentPlaceSearch() {
        isPlaceSearchPresented = true
    }

    func dismissPlaceSearch() {
        isPlaceSearchPresented = false
    }

    func selectVendor(_ id: Vendor.ID?) {
        selectedVendorID = id
    }
}
