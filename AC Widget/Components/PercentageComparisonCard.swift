//
//  PercentageComparisonCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import BetterToStrings

struct PercentageComparisonCard: View {
    let mainType: InfoType
    let comparisonType: InfoType
    let header: Bool
    let title: LocalizedStringKey
    let mainValue: Float
    let comparisonValue: Float

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                if header {
                    Label(mainType.stringKey, systemImage: mainType.systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(mainType.color)
                }
                Text(title)
                    .font(.title2.weight(.semibold))
                Divider()

                VStack(spacing: 6) {
                    HStack {
                        Text(mainType.stringKey)
                            .foregroundColor(mainType.color)
                        Spacer()
                        Text(comparisonType.stringKey)
                            .foregroundColor(comparisonType.color)
                    }
                    .font(.caption.weight(.medium))

                    HStack {
                        Text(mainValue.toString(abbreviation: .intelligent))
                        Spacer()
                        Text(comparisonValue.toString(abbreviation: .intelligent))
                    }
                    .font(.system(size: 34, weight: .semibold, design: .rounded))

                    GeometryReader { val in
                        HStack(spacing: 5) {
                            Rectangle()
                                .foregroundColor(mainType.color)
                                .frame(width: (val.size.width-5)*CGFloat(mainValue/(mainValue + comparisonValue)))

                            Rectangle()
                                .foregroundColor(comparisonType.color)
                                .frame(width: (val.size.width-5)*CGFloat(comparisonValue/(mainValue + comparisonValue)))
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 16)
                }
            }
        }
    }
}

struct PercentageComparisonCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PercentageComparisonCard(mainType: .reDownloads,
                                     comparisonType: .downloads,
                                     header: true,
                                     title: "12.3% of your total downloads were re-downloaded.",
                                     mainValue: 82,
                                     comparisonValue: 815)
                .frame(maxHeight: 300)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))

            PercentageComparisonCard(mainType: .reDownloads,
                                     comparisonType: .downloads,
                                     header: true,
                                     title: "12.3% of your total downloads were re-downloaded.",
                                     mainValue: 110,
                                     comparisonValue: 815)
                .frame(maxHeight: 300)
                .padding()
                .preferredColorScheme(.dark)
        }
    }
}
