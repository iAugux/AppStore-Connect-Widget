//
//  DownloadsView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct DownloadsView: View {
    @EnvironmentObject private var provider: ACDataProvider

    var data: ACData {
        return provider.data ?? .example
    }

    var body: some View {
        ScrollView {
            downloadsSection
            reDownloadsSection
        }
        .navigationTitle("DOWNLOADS")
        .secondaryBackground()
    }

    private var downloadsSection: some View {
        CardSection {
            SummaryCard(type: .downloads, header: false)
            WeeklyAverageComparisonCard(type: .downloads, header: false)
        }
    }

    private var reDownloadsSection: some View {
        CardSection("REDOWNLOADS") {
            SummaryCard(type: .reDownloads, header: true)
        }
    }
}

struct DownloadsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DownloadsView()
        }
        .environmentObject(ACDataProvider.example)
    }
}
