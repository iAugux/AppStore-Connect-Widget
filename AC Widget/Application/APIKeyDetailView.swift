//
//  APIKeyDetailView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct APIKeyDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var apiKeysProvider: APIKeyProvider

    let key: APIKey
    @State private var keyName: String
    @State private var keyColor: Color
    private var issuerID: String
    private var privateKeyID: String
    private var privateKey: String
    private var vendorNumber: String

    @State private var status: APIError?

    @State private var apps: [ACApp] = []
    @State private var cachedEntries: Int

    init(_ key: APIKey) {
        self.key = key
        _keyName = State(initialValue: key.name)
        _keyColor = State(initialValue: key.color)
        _cachedEntries = State(initialValue: ACDataCache.numberOfEntriesCached(apiKey: key))
        issuerID = key.issuerID
        privateKeyID = key.privateKeyID
        privateKey = key.privateKey
        vendorNumber = key.vendorNumber
    }

    var body: some View {
        Form {
            namingSection
            if let status = status {
                Section {
                    ErrorWidget(error: status)
                }
                .frame(maxHeight: 250)
            }
            keySection
            appListSection
            storageSection
            deleteSection
        }
        .task {
            do {
                try await key.checkKey()
                try await loadApps()
            } catch let err {
                status = (err as? APIError) ?? .unknown
            }
        }
        .navigationTitle(keyName)
    }

    var appListSection: some View {
        Section(header: Label("APP_LIST", systemImage: "app.fill")) {
            AppListView(apps: apps)
        }
    }

    var namingSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 0.0) {
                Text("KEY_NAME")
                    .bold()

                TextField("KEY_NAME", text: $keyName)
            }

            ColorPicker("KEY_COLOR", selection: $keyColor, supportsOpacity: false)

            Button("SAVE", action: save)
        }
    }

    var keySection: some View {
        Section(footer: Text("KEY_DETAIL_FOOTER")) {
            VStack(alignment: .leading, spacing: 0.0) {
                Text("ISSUER_ID")
                    .bold()

                Text(issuerID)
                    .textSelection(.enabled)
            }

            VStack(alignment: .leading, spacing: 0.0) {
                Text("PRIVATE_KEY_ID")
                    .bold()

                Text(privateKeyID)
                    .textSelection(.enabled)
            }

            VStack(alignment: .leading, spacing: 0.0) {
                Text("PRIVATE_KEY")
                    .bold()

                Text(privateKey)
                    .textSelection(.enabled)
            }

            VStack(alignment: .leading, spacing: 0.0) {
                Text("VENDOR_NR")
                    .bold()

                Text(vendorNumber)
                    .textSelection(.enabled)
            }
        }
    }

    private func loadApps() async throws {
        let api = AppStoreConnectApi(apiKey: key)
        let data = try await api.getData(currency: Currency.USD, useCache: true)
        apps = data.apps
    }

    private func save() {
        try? apiKeysProvider.addApiKey(apiKey: APIKey(name: keyName,
                                                      color: keyColor,
                                                      issuerID: issuerID,
                                                      privateKeyID: privateKeyID,
                                                      privateKey: privateKey,
                                                      vendorNumber: vendorNumber))
    }

    var storageSection: some View {
        Section(header: Label("STORAGE", systemImage: "externaldrive.fill")) {
            Text("CACHED_ENTRIES:\(cachedEntries)")

            Button("CLEAR_CACHE") {
                AppStoreConnectApi.clearMemoization()
                APIKey.clearMemoization()
                ACDataCache.clearCache(apiKey: key)
                self.cachedEntries = ACDataCache.numberOfEntriesCached(apiKey: key)
            }
            .foregroundColor(.orange)
        }
    }

    @State var showingDeleteAlert = false
    var deleteSection: some View {
        Section {
            Button("DELETE_KEY") {
                showingDeleteAlert.toggle()
            }
            .foregroundColor(.red)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("CONFIRM_DELETE_KEY"),
                message: Text("DELETE_NO_UNDO"),
                primaryButton: .destructive(Text("DELETE_KEY")) {
                    ACDataCache.clearCache(apiKey: key)
                    apiKeysProvider.deleteApiKeys(keys: [key])
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

struct APIKeyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            APIKeyDetailView(APIKey.example)
        }
    }
}
