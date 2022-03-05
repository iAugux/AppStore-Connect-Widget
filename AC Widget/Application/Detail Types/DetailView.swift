//
//  DetailView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct DetailView: View {
    let type: InfoType
    let secondaryType: InfoType?

    init(type: InfoType, secondaryType: InfoType? = nil) {
        self.type = type
        self.secondaryType = secondaryType
    }

    var body: some View {
        ScrollView {
            mainSection
            if let secondaryType = secondaryType {
                secondarySection(secondaryType)
            }
        }
        .navigationTitle(type.title)
        .secondaryBackground()
    }

    private var mainSection: some View {
        CardSection {
            SummaryCard(type: type, header: false)
            MonthlyGoalCard(type: type, header: false)
            HeatMapCard(type: type, header: false)
            WeeklyAverageCard(type: type, header: false)
            ComparisonCard(type: type, header: false, interval: .sevenDays)
            CountryRankingCard(type: type, header: false)
            WeeklyAverageComparisonCard(type: type, header: false)
            ComparisonCard(type: type, header: false, interval: .thirtyDays)
            YearlyOverviewCard(type: type, header: false)
        }
    }

    private func secondarySection(_ secondType: InfoType) -> some View {
        CardSection(secondType.title) {
            SummaryCard(type: secondType, header: true)
            PercentageComparisonCard(type: secondType, header: true)
            WeeklyAverageCard(type: secondType, header: true)
            ComparisonCard(type: secondType, header: false, interval: .thirtyDays)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailView(type: .downloads, secondaryType: .reDownloads)
        }
        .environmentObject(ACDataProvider.example)
    }
}
