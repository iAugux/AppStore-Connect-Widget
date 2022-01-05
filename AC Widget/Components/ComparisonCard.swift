//
//  ComparisonCard.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 03.01.22.
//

import SwiftUI
import BetterToStrings

struct ComparisonCard: View {
    let type: InfoType
    let header: Bool
    let title: LocalizedStringKey
    let primaryValue: Float
    let primaryLabel: LocalizedStringKey
    let secondaryValue: Float
    let secondaryLabel: LocalizedStringKey

    var body: some View {
        Card {
            GeometryReader { val in
                VStack(alignment: .leading, spacing: 10) {
                    if header {
                        Label(type.stringKey, systemImage: type.systemImage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(type.color)
                    }
                    Text(title)
                        .font(.title2.weight(.semibold))
                    Divider()

                    VStack(alignment: .leading, spacing: 1) {
                        UnitText(primaryValue.toString(abbreviation: .intelligent), metricSymbol: type.systemImage)
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

                    VStack(alignment: .leading, spacing: 1) {
                        UnitText(secondaryValue.toString(abbreviation: .intelligent), metricSymbol: type.systemImage)

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .foregroundColor(Color(uiColor: .systemGray4))
                                .frame(width: val.size.width * CGFloat(secondaryValue/max(primaryValue, secondaryValue)), height: 30)

                            Text(primaryLabel)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.leading, 8)
                        }
                    }
                }
            }
        }
    }
}

struct ComparisonCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ComparisonCard(type: .downloads,
                           header: true,
                           title: "You had 1.234 less downloads this month than last one.",
                           primaryValue: 1714,
                           primaryLabel: "December",
                           secondaryValue: 2968,
                           secondaryLabel: "November"
            )
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))
            
            ComparisonCard(type: .downloads,
                           header: true,
                           title: "You had 1.234 less downloads this month than last one.",
                           primaryValue: 1714,
                           primaryLabel: "December",
                           secondaryValue: 2968,
                           secondaryLabel: "November"
            )
                .padding()
                .background(Color.black)
                .preferredColorScheme(.dark)
        }
    }
}
