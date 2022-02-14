//
//  PercentageComparisonCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import BetterToStrings

struct PercentageComparisonCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    let type: InfoType
    let header: Bool
    @State private var title: LocalizedStringKey = ""
    @State private var mainValue: Float = 0
    @State private var comparisonValue: Float = 0

    var comparisonType: InfoType {
        switch type {
        case .reDownloads:
            return .downloads
        case .restoredIap:
            return .iap
        default:
            return .downloads
        }
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                if header {
                    Label(type.stringKey, systemImage: type.systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(type.color)
                }
                Text(title)
                    .font(.title2.weight(.semibold))
                Divider()

                VStack(spacing: 6) {
                    HStack {
                        Text(comparisonType.stringKey)
                            .foregroundColor(comparisonType.color)
                        Spacer()
                        Text(type.stringKey)
                            .foregroundColor(type.color)
                    }
                    .font(.caption.weight(.medium))

                    HStack {
                        Text(comparisonValue.toString(abbreviation: .intelligent))
                        Spacer()
                        Text(mainValue.toString(abbreviation: .intelligent))
                    }
                    .font(.system(size: 34, weight: .semibold, design: .rounded))

                    GeometryReader { val in
                        HStack(spacing: 5) {
                            Rectangle()
                                .foregroundColor(comparisonType.color)
                                .frame(width: (val.size.width-5)*CGFloat(comparisonValue/(mainValue + comparisonValue)))

                            Rectangle()
                                .foregroundColor(type.color)
                                .frame(width: (val.size.width-5)*CGFloat(mainValue/(mainValue + comparisonValue)))
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 16)
                }
            }
        }
        .onAppear(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
    }

    private func refresh() {
        if let acData = dataProvider.data {
            self.mainValue = acData.getRawData(for: type, lastNDays: 30).reduce(0, { $0 + $1.0 })
            self.comparisonValue = acData.getRawData(for: comparisonType, lastNDays: 30).reduce(0, { $0 + $1.0 })

            if mainValue == 0 && comparisonValue == 0 { return } // check if division by zero
            let percentage = (mainValue / (mainValue + comparisonValue))*100

            switch type {
            case .reDownloads:
                self.title = "\(percentage.toString(abbreviation: .none, maxFractionDigits: 1))% of your total downloads were re-downloaded."
            case .restoredIap:
                self.title = "\(percentage.toString(abbreviation: .none, maxFractionDigits: 1))% of your total in-app purchases were restored."
            default:
                self.title = "ERROR"
            }
        }
    }
}

struct PercentageComparisonCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                PercentageComparisonCard(type: .reDownloads, header: true)
                PercentageComparisonCard(type: .restoredIap, header: true)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)

            CardSection {
                PercentageComparisonCard(type: .reDownloads, header: true)
                PercentageComparisonCard(type: .restoredIap, header: true)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)
            .preferredColorScheme(.dark)
        }
    }
}
