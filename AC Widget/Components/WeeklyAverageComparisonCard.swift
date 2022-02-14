//
//  WeeklyAverageComparisonCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct WeeklyAverageComparisonCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider

    @State private var type: InfoType
    @State private var header: Bool

    @State private var title: String = ""
    @State private var data: [RawDataPoint] = []
    @State private var average1: Float = 1
    @State private var average2: Float = 1
    @State private var max: Float = 1

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
                Text(title)
                    .font(.title2.weight(.semibold))
                Divider()
                if max != 0 {
                    VStack(spacing: 5) {
                        averagesText

                        ZStack(alignment: .top) {
                            graph
                            line
                        }

                        dateRanges
                    }
                } else {
                    Text("NO_DATA")
                }
            }
        }
        .onAppear(perform: refresh)
        .onReceive(dataProvider.$data) { _ in refresh() }
    }

    private var averagesText: some View {
        HStack {
            if type == .proceeds {
                UnitText(average1.toString(abbreviation: .intelligent, maxFractionDigits: 2), metric: currencySymbol)
                Spacer()
                UnitText(average2.toString(abbreviation: .intelligent, maxFractionDigits: 2), metric: currencySymbol)
            } else {
                UnitText(average1.toString(abbreviation: .intelligent, maxFractionDigits: 2), metricSymbol: type.systemImage)
                Spacer()
                UnitText(average2.toString(abbreviation: .intelligent, maxFractionDigits: 2), metricSymbol: type.systemImage)
            }
        }
        .foregroundColor(type.color)
    }

    private var dateRanges: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                HStack(spacing: 3) {
                    Capsule()
                        .frame(width: -1.5 + (31 - 7) * geo.size.width / 31)

                    Capsule()
                        .frame(width: -1.5 + 7 * geo.size.width / 31)
                }
            }
            .frame(height: 1, alignment: .bottom)

            HStack {
                Text(firstDateIntervall).fixedSize(horizontal: true, vertical: false)
                Spacer()
                Text(secondDateIntervall).fixedSize(horizontal: true, vertical: false)
            }
            .font(.system(size: 9))
        }
        .foregroundColor(Color(uiColor: .systemGray4))
    }

    private var graph: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(data, id: \.1) { (value, date) in
                    VStack {
                        Capsule()
                            .frame(width: 0.5 * geo.size.width / 31, height: geo.size.height * CGFloat(value/max))
                        //                        Text(date.toString(format: "EEEEE"))
                    }
                    .foregroundColor(Color(uiColor: .systemGray4))
                    if data.last?.1 != date {
                        Spacer(minLength: 0)
                    }
                }
            }
        }
    }

    private var line: some View {
        GeometryReader { geo in
            HStack(spacing: 3) {
                Capsule()
                    .frame(width: -1.5 + (31 - 7) * geo.size.width / 31, height: 6)
                    .offset(x: 0, y: geo.size.height - (geo.size.height * CGFloat(average1/max)) - 3)

                Capsule()
                    .frame(width: -1.5 + 7 * geo.size.width / 31, height: 6)
                    .offset(x: 0, y: geo.size.height - (geo.size.height * CGFloat(average2/max)) - 3)
            }
            .foregroundColor(type.color)
        }
    }

    private var firstDateIntervall: String {
        let days = self.data.dropLast(7).map(\.1)
        return formatDateRange(days)
    }
    private var secondDateIntervall: String {
        let days = self.data.suffix(7).map(\.1)
        return formatDateRange(days)
    }

    private func formatDateRange(_ days: [Date]) -> String {
        let sorted = days.sorted()
        guard let first = sorted.first, let last = sorted.last else { return "" }
        return first.toString(format: "dd. MMM") + "-" + last.toString(format: "dd. MMM")
    }

    private var currencySymbol: String {
        return dataProvider.displayCurrencySymbol
    }

    private func refresh() {
        guard let providedData = dataProvider.data else { return }

        let rawData = providedData.getRawData(for: type, lastNDays: 31)
        let filteredData = Array(rawData.sorted(by: { $0.1 < $1.1 }))
        self.data = filteredData

        if filteredData.isEmpty {
            self.average1 = .zero
            self.average2 = .zero
        } else {
            self.average1 = filteredData.dropLast(7).map(\.0).average()
            self.average2 = filteredData.suffix(7).map(\.0).average()
        }

        self.max = filteredData.map(\.0).max() ?? 0

        let avgChange = average2 - average1
        let avgChangeAbs: String = abs(avgChange).toString(abbreviation: .intelligent, maxFractionDigits: 1)
        switch type {
        case .downloads, .updates, .iap, .reDownloads, .restoredIap:
            if avgChange == 0 {
                self.title = "Your average \(type.title.lowercased()) didn't change."
            } else if avgChange < 0 {
                self.title = "Your app had \(avgChangeAbs) \(type.title.lowercased()) less this week than before."
            } else {
                self.title = "Your app had \(avgChangeAbs) \(type.title.lowercased()) more this week than before."
            }
        case .proceeds:
            if avgChange == 0 {
                self.title = "Your average earnings didn't change."
            } else if avgChange < 0 {
                self.title = "You earned \(abs(avgChange).toString(abbreviation: .intelligent, maxFractionDigits: 2))\(currencySymbol) less this week than before."
            } else {
                self.title = "You earned \(abs(avgChange).toString(abbreviation: .intelligent, maxFractionDigits: 2))\(currencySymbol) more this week than before."
            }
        }
    }
}

struct WeeklyAverageComparisonCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                WeeklyAverageComparisonCard(type: .downloads, header: true)
            }
            .secondaryBackground()

            CardSection {
                WeeklyAverageComparisonCard(type: .downloads, header: false)
            }
            .secondaryBackground()
            .preferredColorScheme(.dark)
        }
        .environmentObject(ACDataProvider.exampleLargeSums)
    }
}
