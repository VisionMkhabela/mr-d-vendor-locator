import SwiftUI

struct VendorRow: View {
    let vendor: Vendor
    let onFavorite: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(vendor.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(vendor.address)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if !vendor.hasCoordinate {
                    Text("No map pin yet")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Spacer(minLength: 8)

            FavoriteButton(isFavorite: vendor.isFavorite, action: onFavorite)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VendorRow(vendor: .sample, onFavorite: {})
        .padding()
}
