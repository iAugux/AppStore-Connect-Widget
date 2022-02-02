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
            SummaryCard(data: data, type: .downloads, header: false)
            ComparisonCard(type: .downloads,
                           header: false,
                           title: "You earned 254$ less this week than last one.",
                           primaryValue: 200,
                           primaryLabel: "December",
                           secondaryValue: 318,
                           secondaryLabel: "November")
            WeeklyAverageComparisonCard(type: .downloads, header: false, title: "Your average earnings this week, are 3.7$ less.", data: [])
        }
    }

    private var reDownloadsSection: some View {
        CardSection("REDOWNLOADS") {
            SummaryCard(data: data, type: .reDownloads, header: true)
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
