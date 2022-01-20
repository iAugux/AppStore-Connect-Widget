//
//  HomeView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import AppStoreConnect_Swift_SDK
import StoreKit

struct HomeView: View {
    @EnvironmentObject var dataProvider: ACDataProvider

    @State var showSettings = false

    @AppStorage(UserDefaultsKey.appStoreNotice, store: UserDefaults.shared) var appStoreNotice: Bool = true

    @AppStorage(UserDefaultsKey.rateCount, store: UserDefaults.shared) var rateCount: Int = 0

    @State var tiles: [TileType] = []

    @AppStorage(UserDefaultsKey.lastSeenVersion, store: UserDefaults.shared) private var lastSeenVersion: String = ""
    @State private var showsUpdateScreen = false

    var body: some View {
        RefreshableScrollView(onRefresh: {
            await dataProvider.refreshData(useMemoization: false)
        }) {
            if let data = dataProvider.data {
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
        .sheet(isPresented: $showsUpdateScreen, content: {
            UpdateView()
        })
        .onAppear(perform: onAppear)
//        .onChange(of: keyID, perform: { _ in Task { await dataProvider.refreshData(useMemoization: false) } })
//        .onChange(of: currency, perform: { _ in Task { await dataProvider.refreshData(useMemoization: false) } })
        .task { await dataProvider.refreshData(useMemoization: true) }
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//            Task { await onAppear() }
//        }
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
            Text("LAST_CHANGE:\(dataProvider.data?.latestReportingDate() ?? "-")")
                .font(.subheadline)
            Spacer()
        }
        .padding(.horizontal)
    }

    var additionalInformation: some View {
        VStack(spacing: 20) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 8) {
                Text("LAST_CHANGE:\(dataProvider.data?.latestReportingDate() ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("CURRENCY:\(dataProvider.data?.displayCurrency.rawValue ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("API_KEY:\(dataProvider.selectedKey?.name ?? "-")")
                    .font(.system(size: 12))
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if dataProvider.data != nil {
                AsyncButton(action: {
                    await dataProvider.refreshData(useMemoization: false)
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

    private func onAppear() {
        askToRate()

        let selectedTiles = UserDefaults.shared?.stringArray(forKey: UserDefaultsKey.tilesInHome)?.compactMap({ TileType(rawValue: $0) }) ?? []
        tiles = selectedTiles.isEmpty ? TileType.allCases : selectedTiles
//
//        guard let apiKey = selectedKey else { return }
//        let api = AppStoreConnectApi(apiKey: apiKey)
//        do {
//            self.data = try await api.getData(currency: Currency(rawValue: currency), useMemoization: useMemoization)
//        } catch let err as APIError {
//            self.error = err
//        } catch {}
//
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
                HomeView(tiles: TileType.allCases)
            }

            NavigationView {
                HomeView(tiles: TileType.allCases)
            }
            .preferredColorScheme(.dark)
        }
        .environmentObject(APIKeyProvider.example)
        .environmentObject(ACDataProvider.example)
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
