//
//  ContentView.swift
//  AC Widget by NO-COMMENT
//

import AppStoreConnect_Swift_SDK
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var apiKeysProvider: APIKeyProvider

    var completedOnboarding: Bool {
        return !apiKeysProvider.apiKeys.isEmpty
    }

    var body: some View {
        NavigationView {
            if completedOnboarding {
                HomeView()
            } else {
                OnboardingView(showsWelcome: true)
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
