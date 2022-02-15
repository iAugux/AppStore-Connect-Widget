//
//  NoDataOverlay.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct NoDataOverlayView: View {
    var body: some View {
        Text("There is currently no data for this graph")
            .bold()
            .multilineTextAlignment(.center)
            .padding()
            .background(.thinMaterial)
            .cornerRadius(9)
            .unredacted()
            .minimumScaleFactor(0.8)
            .frame(width: 220)
    }
}

extension View {
    func noDataOverlay(_ condition: Bool) -> some View {
        self
            .overlay(NoDataOverlayView().opacity(condition ? 1 : 0), alignment: .center)
            .redacted(reason: condition ? .placeholder : [])
    }
}

struct NoDataOverlay_Previews: PreviewProvider {
    static var previews: some View {
        LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
            .noDataOverlay(true)

        CardSection {
            YearlyOverviewCard(type: .downloads, header: true)
            YearlyOverviewCard(type: .proceeds, header: true)
        }
        .secondaryBackground()
        .environmentObject(ACDataProvider.exampleNoData)
    }
}
