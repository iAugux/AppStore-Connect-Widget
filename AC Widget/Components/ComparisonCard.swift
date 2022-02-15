//
//  ComparisonCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import BetterToStrings

struct ComparisonCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    let type: InfoType
    let header: Bool
    let interval: TimeIntervall
    @State private var title: String = ""
    @State private var primaryValue: Float = 0
    @State private var primaryLabel: String = ""
    @State private var secondaryValue: Float = 0
    @State private var secondaryLabel: String = ""

    var body: some View {
        Card {
            GeometryReader { val in
                VStack(alignment: .leading, spacing: 10) {
                    if header {
                        Label(type.title, systemImage: type.systemImage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(type.color)
                    }
                    Text(title)
                        .font(.title2.weight(.semibold))
                    Divider()

                    VStack(alignment: .leading, spacing: 1) {
                        UnitText(primaryValue.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(type.color)
                                .frame(width: val.size.width * CGFloat(primaryValue/max(primaryValue, secondaryValue)), height: 30)

                            Text(primaryLabel)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(type.contrastColor)
                                .padding(.leading, 8)
                        }
                    }
                    Spacer(minLength: 0)
                    VStack(alignment: .leading, spacing: 1) {
                        UnitText(secondaryValue.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: dataProvider.displayCurrencySymbol)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(Color(uiColor: .systemGray4))
                                .frame(width: val.size.width * CGFloat(secondaryValue/max(primaryValue, secondaryValue)), height: 30)

                            Text(secondaryLabel)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.leading, 8)
                        }
                    }
                }
            }
        }
        .onAppear(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
    }

    private func refresh() {
        if let acData = dataProvider.data {
            self.primaryValue = acData.getRawData(for: type, lastNDays: interval.lastNDays).reduce(0, { $0 + $1.0 })
            self.secondaryValue = acData.getRawData(for: type, lastNDays: 2*interval.lastNDays).reduce(0, { $0 + $1.0 }) - primaryValue
            self.primaryLabel = interval.primaryLabel
            self.secondaryLabel = interval.secondaryLabel

            switch type {
            case .downloads, .updates, .restoredIap, .reDownloads, .iap:
                if primaryValue == secondaryValue {
                    self.title = "Your average \(type.title.lowercased()) in the last \(interval.sentenceBlock) were the same as before."
                } else if primaryValue < secondaryValue {
                    self.title = "You had more \(type.title.lowercased()) in the last \(interval.sentenceBlock) than before."
                } else {
                    self.title = "You had less \(type.title.lowercased()) in the last \(interval.sentenceBlock) than before."
                }
            case .proceeds:
                if primaryValue == secondaryValue {
                    self.title = "Your earnings in the last \(interval.sentenceBlock) did not change."
                } else if primaryValue < secondaryValue {
                    self.title = "You earned more in the last \(interval.sentenceBlock) than before."
                } else {
                    self.title = "You earned less in the last \(interval.sentenceBlock) than before."
                }
            }
        }
    }
}

struct ComparisonCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                ComparisonCard(type: .downloads, header: true, interval: .sevenDays)
                ComparisonCard(type: .proceeds, header: true, interval: .thirtyDays)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)

            CardSection {
                ComparisonCard(type: .downloads, header: true, interval: .sevenDays)
                ComparisonCard(type: .proceeds, header: true, interval: .thirtyDays)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)
            .preferredColorScheme(.dark)
        }
    }
}

enum TimeIntervall {
    case thirtyDays, sevenDays
    // case lastMonth, lastWeek
    // case quarter, semester, year

    var lastNDays: Int {
        switch self {
        case .thirtyDays:
            return 30
        case .sevenDays:
            return 7
        }
    }

    var primaryLabel: String {
        switch self {
        case .thirtyDays:
            return "Last 30 days"
        case .sevenDays:
            return "Last 7 days"
        }
    }

    var secondaryLabel: String {
        switch self {
        case .thirtyDays:
            return "Previous 30 days"
        case .sevenDays:
            return "Previous 7 days"
        }
    }

    var sentenceBlock: String {
        switch self {
        case .thirtyDays:
            return "30 days"
        case .sevenDays:
            return "7 days"
        }
    }
}
