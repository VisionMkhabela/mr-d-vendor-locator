import CoreLocation
import GoogleMaps
import SwiftUI

struct GoogleMapView: UIViewRepresentable {
    var vendors: [Vendor]
    var selectedVendorID: Vendor.ID?
    var colorScheme: ColorScheme
    var onSelect: (Vendor.ID) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition(latitude: -33.9249, longitude: 18.4241, zoom: 11)
        let mapView = GMSMapView(options: options)
        mapView.delegate = context.coordinator
        applyStyle(to: mapView, colorScheme: colorScheme)
        return mapView
    }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        context.coordinator.onSelect = onSelect
        applyStyle(to: mapView, colorScheme: colorScheme)
        syncMarkers(on: mapView, coordinator: context.coordinator)

        guard selectedVendorID != context.coordinator.lastSelectedID else { return }
        context.coordinator.lastSelectedID = selectedVendorID

        if let vendor = vendors.first(where: { $0.id == selectedVendorID }),
           let coordinate = vendor.coordinate {
            let camera = GMSCameraPosition(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                zoom: 15
            )
            mapView.animate(to: camera)
        }
    }

    private func applyStyle(to mapView: GMSMapView, colorScheme: ColorScheme) {
        if let json = MapStyle.json(for: colorScheme) {
            mapView.mapStyle = try? GMSMapStyle(jsonString: json)
        } else {
            mapView.mapStyle = nil
        }
    }

    private func syncMarkers(on mapView: GMSMapView, coordinator: Coordinator) {
        mapView.clear()
        coordinator.markers.removeAll()

        for vendor in vendors {
            guard let coordinate = vendor.coordinate else { continue }
            let marker = GMSMarker(
                position: CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
            )
            marker.title = vendor.name
            marker.snippet = vendor.address
            marker.userData = vendor.id
            marker.groundAnchor = CGPoint(x: 0.5, y: 1)
            marker.icon = vendor.isFavorite
            ? MarkerIcon.favorite
                : MarkerIcon.vendor
            marker.map = mapView
            coordinator.markers[vendor.id] = marker
        }
    }

    private enum MarkerIcon {
        static let pointSize: CGFloat = 40
        static let vendor: UIImage? = UIImage(named: "icon-annotation")?.fitted(to: pointSize)
        static let favorite: UIImage? = UIImage(named: "icon-fav")?.fitted(to: pointSize)

    }

    final class Coordinator: NSObject, GMSMapViewDelegate {
        var onSelect: (Vendor.ID) -> Void
        var lastSelectedID: Vendor.ID?
        var markers: [Vendor.ID: GMSMarker] = [:]

        init(onSelect: @escaping (Vendor.ID) -> Void) {
            self.onSelect = onSelect
        }

        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            if let id = marker.userData as? Vendor.ID {
                onSelect(id)
            }
            return false
        }
    }
}

private extension UIImage {
    func fitted(to maxDimension: CGFloat) -> UIImage {
        let longestSide = max(size.width, size.height)
        guard longestSide > 0 else { return self }

        let scale = maxDimension / longestSide
        let targetSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
