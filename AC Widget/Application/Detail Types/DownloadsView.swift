//
//  DownloadsView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct DownloadsView: View {
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
            ComparisonCard(type: .downloads,
                           header: false,
                           title: "You earned 254$ less this week than last one.",
                           primaryValue: 200,
                           primaryLabel: "December",
                           secondaryValue: 318,
                           secondaryLabel: "November")
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
