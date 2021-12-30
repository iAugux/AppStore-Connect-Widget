//
//  HomeView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import AppStoreConnect_Swift_SDK
import StoreKit

struct HomeView: View {
    @State var data: ACData?
    @State var error: APIError?
    @State var showingSheet: Bool = false

    @State var showSettings = false

    @EnvironmentObject var apiKeysProvider: APIKeyProvider

    @AppStorage(UserDefaultsKey.appStoreNotice, store: UserDefaults.shared) var appStoreNotice: Bool = true
    @AppStorage(UserDefaultsKey.homeSelectedKey, store: UserDefaults.shared) private var keyID: String = ""
    @AppStorage(UserDefaultsKey.homeCurrency, store: UserDefaults.shared) private var currency: String = "USD"
    @AppStorage(UserDefaultsKey.rateCount, store: UserDefaults.shared) var rateCount: Int = 0
    private var selectedKey: APIKey? {
        return apiKeysProvider.getApiKey(apiKeyId: keyID) ?? apiKeysProvider.apiKeys.first
    }

    @State var tiles: [TileType] = []

    @AppStorage(UserDefaultsKey.lastSeenVersion, store: UserDefaults.shared) private var lastSeenVersion: String = ""
    @State private var showsUpdateScreen = false

    var body: some View {
        RefreshableScrollView(onRefresh: {
            await onAppear(useMemoization: false)
        }) {
            if let data = data {
                lastChangeSubtitle
                if appStoreNotice && AppStoreNotice.isTestFlight() {
                    AppStoreNotice()
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
                    ForEach(tiles) { tile in
                        switch tile {
                        case .downloads:
                            InfoTile(description: "DOWNLOADS", data: data, type: .downloads)
                        case .proceeds:
                            InfoTile(description: "PROCEEDS", data: data, type: .proceeds)
                        case .updates:
                            InfoTile(description: "UPDATES", data: data, type: .updates)
                        case .iap:
                            InfoTile(description: "IN-APP-PURCHASES", data: data, type: .iap)
                        case .topCountry:
                            CountryTile(data: data)
                        case .devices:
                            DeviceTile(data: data)
                        }
                    }
                }
                .padding(.horizontal)
                additionalInformation
            } else {
                loadingIndicator
            }
        }
        .background(
            NavigationLink(destination: SettingsView(), isActive: $showSettings) {
                EmptyView()
            }
        )
        .navigationTitle("HOME")
        // .toolbar(content: toolbar)
        .sheet(isPresented: $showingSheet, content: sheet)
        .sheet(isPresented: $showsUpdateScreen, content: {
            UpdateView()
        })
        .onChange(of: keyID, perform: { _ in Task { await onAppear(useMemoization: false) } })
        .onChange(of: currency, perform: { _ in Task { await onAppear(useMemoization: false) } })
        .task { await onAppear(useMemoization: true) }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await onAppear() }
        }
    }

    var loadingIndicator: some View {
        HStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("LOADING_DATA")
                .foregroundColor(.gray)
                .italic()
        }
        .padding(.top, 25)
        .frame(maxWidth: .infinity)
    }

    var lastChangeSubtitle: some View {
        HStack {
            Text("LAST_CHANGE:\(data?.latestReportingDate() ?? "-")")
                .font(.subheadline)
            Spacer()
        }
        .padding(.horizontal)
    }

    var additionalInformation: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                Text("LAST_CHANGE:\(data?.latestReportingDate() ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("CURRENCY:\(data?.displayCurrency.rawValue ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("API_KEY:\(selectedKey?.name ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if data != nil {
                AsyncButton(action: {
                    await onAppear(useMemoization: false)
                }) {
                    Text("REFRESH_DATA")
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 20)
                .background(Color.cardColor)
                .clipShape(Capsule())
                .foregroundColor(.primary)
            }
        }
        .foregroundColor(.gray)
        .padding()
    }

    func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button(action: { showingSheet.toggle() }, label: {
                Image(systemName: "key")
            })
        }
    }

    func sheet() -> some View {
        NavigationView {
            KeySelectionView()
                .closeSheetButton()
        }
    }

    private func onAppear(useMemoization: Bool = true) async {
        askToRate()

        let selectedTiles = UserDefaults.shared?.stringArray(forKey: UserDefaultsKey.tilesInHome)?.compactMap({ TileType(rawValue: $0) }) ?? []
        tiles = selectedTiles.isEmpty ? TileType.allCases : selectedTiles

        guard let apiKey = selectedKey else { return }
        let api = AppStoreConnectApi(apiKey: apiKey)
        do {
            self.data = try await api.getData(currency: Currency(rawValue: currency), useMemoization: useMemoization)
        } catch let err as APIError {
            self.error = err
        } catch {}

        let appVersion: String = UIApplication.appVersion ?? ""
        let buildVersion: String = UIApplication.buildVersion ?? ""
        let vString = "\(appVersion) (\(buildVersion))"
        if vString != lastSeenVersion {
            lastSeenVersion = vString
            showsUpdateScreen = true
            appStoreNotice = true
        }
    }

    func askToRate() {
        let daysSinceInstall = Calendar.current.numberOfDaysBetween(Date.appInstallDate, and: .now)
        if daysSinceInstall > (rateCount + 1) * 20 {
            // equivalent to rateCount += 1 in most cases, except if app is installed a long time ago but no review done
            rateCount = Int(ceil(Double(daysSinceInstall - 20) / 20))
            let later = DispatchTime.now() + 5
            DispatchQueue.main.asyncAfter(deadline: later) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                HomeView(data: ACData.example, tiles: TileType.allCases)
            }

            NavigationView {
                HomeView(data: ACData.example, tiles: TileType.allCases)
            }
            .preferredColorScheme(.dark)
        }
    }
}

enum TileType: String, CaseIterable, Identifiable {
    case downloads
    case proceeds
    case updates
    case topCountry
    case devices
    case iap

    var localized: LocalizedStringKey { return .init(rawValue) }
    var id: String { return rawValue }
}
