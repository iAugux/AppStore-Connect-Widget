//
//  NoDataOverlay.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct NoDataOverlayView: View {
    let short: Bool

    var body: some View {
        Text(short ? "No Data" : "There is currently no data for this graph")
            .bold()
            .multilineTextAlignment(.center)
            .padding(short ? 8 : 15)
            .background(.thinMaterial)
            .cornerRadius(9)
            .unredacted()
            .minimumScaleFactor(0.8)
            .frame(width: 220)
    }
}

extension View {
    func noDataOverlay(_ condition: Bool, short: Bool = false) -> some View {
        self
            .overlay(NoDataOverlayView(short: short).opacity(condition ? 1 : 0), alignment: .center)
            .redacted(reason: condition ? .placeholder : [])
    }
}

struct NoDataOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
        LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
            VStack {
                NoDataOverlayView(short: true)
                NoDataOverlayView(short: false)
            }
        }

        CardSection {
            YearlyOverviewCard(type: .downloads, header: true)
            YearlyOverviewCard(type: .proceeds, header: true)
        }
        .secondaryBackground()
        .environmentObject(ACDataProvider.exampleNoData)
    }
}
