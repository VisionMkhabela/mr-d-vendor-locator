import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Circle()
                            .fill(viewModel.hasStoredToken ? Color.green : Color.secondary)
                            .frame(width: 10, height: 10)
                        Text(viewModel.hasStoredToken ? "Token stored in Keychain" : "No token stored")
                            .foregroundStyle(.primary)
                    }
                } header: {
                    Text("Session")
                } footer: {
                    Text("The token is attached as an Authorization Bearer header on every simulated API call.")
                }

                Section("Token") {
                    SecureField("Enter session token", text: $viewModel.draftToken)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                    Button("Save to Keychain") {
                        viewModel.save()
                    }
                    .disabled(viewModel.draftToken.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Button("Clear token", role: .destructive) {
                        viewModel.clear()
                    }
                    .disabled(!viewModel.hasStoredToken)
                }

                Section("Demo") {
                    Button {
                        Task { await viewModel.loadDemoToken() }
                    } label: {
                        if viewModel.isWorking {
                            ProgressView()
                        } else {
                            Text("Load demo token from API")
                        }
                    }
                    .disabled(viewModel.isWorking)
                }

                if let status = viewModel.statusMessage {
                    Section("Status") {
                        Text(status)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .onAppear { viewModel.refresh() }
        }
    }
}
