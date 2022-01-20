//
//  AC_WidgetApp.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

@main
struct ACWidgetApp: App {
    @StateObject private var dataProvider = ACDataProvider()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataProvider)
                .onAppear {
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
    }
}
