//
//  ContentView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    @EnvironmentObject var dataProvider: ACDataProvider

    @State var showingSheet: Bool = false

    var completedOnboarding: Bool {
        return !dataProvider.apiKeysProvider.apiKeys.isEmpty
    }

    var body: some View {
        if !completedOnboarding {
            NavigationView {
                OnboardingView(showsWelcome: true)
            }
            .navigationViewStyle(.stack)
        } else if horizontalSizeClass == .compact {
            tabBar
        } else {
            sideBar
        }
    }

    var tabBar: some View {
        TabView {
            NavigationView {
                HomeView()
                    .sheet(isPresented: $showingSheet, content: {
                        NavigationView {
                            KeySelectionView()
                                .closeSheetButton()
                        }
                    })
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(
                                destination: SettingsView(),
                                label: {
                                    Image(systemName: "gear")
                                })
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: { showingSheet.toggle() }, label: {
                                Image(systemName: "key")
                            })
                        }
                    }
            }.tabItem {
                Image(systemName: "house.fill")
                Text("HOME")
            }
            .navigationViewStyle(.stack)

            NavigationView {
                DetailsOverview()
            }.tabItem {
                Image(systemName: "chart.bar.xaxis")
                Text("DETAILS")
            }
            .navigationViewStyle(.stack)

            NavigationView {
                AppListView()
            }.tabItem {
                Image(systemName: "square.grid.2x2.fill")
                Text("APPS")
            }
            .navigationViewStyle(.stack)
        }
    }

    var sideBar: some View {
        NavigationView {
            List {
                NavigationLink(
                    destination: HomeView(),
                    label: {
                        Label("Home", systemImage: "house")
                    })
                NavigationLink(
                    destination: DetailView(type: .downloads, secondaryType: .reDownloads),
                    label: {
                        Label("Downloads", systemImage: "square.and.arrow.down")
                    })
                NavigationLink(
                    destination: DetailView(type: .downloads),
                    label: {
                        Label("Proceeds", systemImage: "dollarsign.circle")
                    })
                NavigationLink(
                    destination: DetailView(type: .downloads),
                    label: {
                        Label("Updates", systemImage: "arrow.triangle.2.circlepath")
                    })
                NavigationLink(
                    destination: EmptyView(),
                    label: {
                        Label("Subscriptions", systemImage: "creditcard")
                    })
                NavigationLink(
                    destination: DetailView(type: .iap, secondaryType: .restoredIap),
                    label: {
                        Label("In-App Purchases", systemImage: "cart")
                    })
                NavigationLink(
                    destination: EmptyView(),
                    label: {
                        Label("Pre-Orders", systemImage: "clock.arrow.circlepath")
                    })
                NavigationLink(
                    destination: SettingsView(),
                    label: {
                        Label("Settings", systemImage: "gear")
                    })

                Section(header: Text("Apps")) {
                    // TODO: List all apps
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Menu")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {  }, label: {
                        Image(systemName: "key")
                    })
                }
            }

            HomeView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(APIKeyProvider.example)
    }
}
