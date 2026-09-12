import SwiftUI

struct ErrorStateView: View {
    let message: String
    let retryTitle: String
    let retry: () -> Void

    init(message: String, retryTitle: String = "Try again", retry: @escaping () -> Void) {
        self.message = message
        self.retryTitle = retryTitle
        self.retry = retry
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(Color.brandRed)

            Text("Something went wrong")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(retryTitle, action: retry)
                .buttonStyle(.borderedProminent)
                .tint(Color.brandRed)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.groupedBackground)
    }
}
