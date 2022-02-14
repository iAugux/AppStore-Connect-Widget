//
//  YearlyOverviewCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct YearlyOverviewCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    private let type: InfoType
    private let header: Bool

    @State private var monthData: [(month: Int, val: Float)] = []
    @State private var maxData: (month: Int, val: Float) = (month: 0, val: 0)

    init(type: InfoType, header: Bool) {
        self.type = type
        self.header = header
    }

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                if header {
                    Label(type.stringKey, systemImage: type.systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(type.color)
                }
                Text(Calendar.current.monthSymbols.indices.contains(maxData.month-1) ? "It looks like \(Calendar.current.monthSymbols[maxData.month-1]) ist your strongest month." : "")
                    .font(.title2.weight(.semibold))

                Divider()
                if !monthData.isEmpty {
                    graph
                } else {
                    Text("NO_DATA")
                }
            }
        }
        .onAppear(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
    }

    private var graph: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom) {
                ForEach(monthData, id: \.month) { (month: Int, val: Float) in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(month == maxData.month ? type.color : Color(uiColor: .systemGray4))
                            .frame(width: geo.size.width/20, height: geo.size.height * CGFloat(val/maxData.val) - 25)

                        Text(Calendar.current.veryShortMonthSymbols[month-1])
                    }
                    .foregroundColor(Color(uiColor: .systemGray4))
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    private func refresh() {
        if let acData = dataProvider.data {
            let rawData = acData.getRawData(for: type, lastNDays: 365)

            let currentMonth = Calendar.current.component(.month, from: .now)
            let monthOrder = Array(currentMonth...(currentMonth + 11)).map({ 1 + $0 % 12 })

            monthData = Dictionary(grouping: rawData) { (data) -> Int in
                return Calendar.current.component(.month, from: data.1)
            }.map { (key: Int, value: [RawDataPoint]) in
                (month: key, val: value.map(\.0).sum())
            }.sorted(by: {
                return (monthOrder.firstIndex(of: $0.month) ?? 13) < (monthOrder.firstIndex(of: $1.month) ?? 13)
            })

            if let max = monthData.max(by: { $0.val < $1.val }) {
                maxData = max
            }
        }
    }
}

struct YearlyOverviewCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                YearlyOverviewCard(type: .downloads, header: true)
                YearlyOverviewCard(type: .proceeds, header: true)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)

            CardSection {
                YearlyOverviewCard(type: .downloads, header: true)
                YearlyOverviewCard(type: .proceeds, header: true)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)
            .preferredColorScheme(.dark)
        }
    }
}
