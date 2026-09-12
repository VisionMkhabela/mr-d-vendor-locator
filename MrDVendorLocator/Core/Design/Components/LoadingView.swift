import SwiftUI

struct LoadingView: View {
    let message: String

    init(_ message: String = "Loading vendors…") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.groupedBackground)
    }
}
