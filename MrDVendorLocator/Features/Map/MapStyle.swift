import GoogleMaps
import SwiftUI

enum MapStyle {
    static func json(for colorScheme: ColorScheme) -> String? {
        colorScheme == .dark ? night : nil
    }

    private static let night = """
    [
      {"elementType":"geometry","stylers":[{"color":"#242f3e"}]},
      {"elementType":"labels.text.fill","stylers":[{"color":"#746855"}]},
      {"elementType":"labels.text.stroke","stylers":[{"color":"#242f3e"}]},
      {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#d59563"}]},
      {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#263c3f"}]},
      {"featureType":"road","elementType":"geometry","stylers":[{"color":"#38414e"}]},
      {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#212a37"}]},
      {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#746855"}]},
      {"featureType":"water","elementType":"geometry","stylers":[{"color":"#17263c"}]}
    ]
    """
}
