import SwiftUI

@main
struct MrDVendorLocatorApp: App {
    @State private var composition = AppFactory.make()

    var body: some Scene {
        WindowGroup {
            RootView(composition: composition)
        }
    }
}
