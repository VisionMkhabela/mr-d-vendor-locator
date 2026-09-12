import SwiftUI

struct FavoriteButton: View {
    let isFavorite: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title3)
                .foregroundStyle(isFavorite ? Color.brandRed : Color.secondary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    }
}
