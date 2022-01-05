//
//  DetailsRow.swift
//  AC Widget
//
//  Created by Miká Kruschel on 03.01.22.
//

import SwiftUI
// infotype
struct DetailsRow: View {
    public let data: ACData
    public let infoType: InfoType

    private var currentDay: (Float, Date) {
        return data.getLastRawData(for: infoType)
    }

    var body: some View {
        Card(spacing: 15, innerPadding: 10) {
            HStack {
                HStack(alignment: .bottom, spacing: 5) {
                    Image(systemName: infoType.systemImage)
                    Text(infoType.stringKey)
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(infoType.color)
                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(data.latestReportingDate())
                    Image(systemName: "chevron.right")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            HStack(alignment: .bottom) {
                if infoType == .proceeds {
                    UnitText(currentDay.0.toString(abbreviation: .intelligent, maxFractionDigits: 2), metric: data.displayCurrency.symbol)
                } else {
                    UnitText(currentDay.0.toString(abbreviation: .intelligent, maxFractionDigits: 2), metricSymbol: infoType.systemImage)
                }
                Spacer(minLength: 70)
                GraphView(ACData.example.getRawData(for: infoType, lastNDays: 30), color: infoType.color)
                    .frame(maxWidth: 230)
            }
            .frame(minHeight: 50)
        }
        .frame(height: 90)
    }
}

struct DetailsRow_Previews: PreviewProvider {
    static var previews: some View {
        DetailsRow(data: .exampleLargeSums, infoType: .iap)
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
        //            .previewInterfaceOrientation(.portrait)
//            .preferredColorScheme(.dark)
//            .environmentObject(ACData.example)
    }
}
