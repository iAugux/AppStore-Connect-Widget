//
//  WeeklyAverageComparisonCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct WeeklyAverageComparisonCard: View {
    @EnvironmentObject var dataProvider: ACDataProvider

    let type: InfoType
    let header: Bool
    let title: LocalizedStringKey
    let data: [(Float, Date)]
    let average1: Float
    let average2: Float
    let max: Float

    init(type: InfoType, header: Bool, title: LocalizedStringKey, data: [(Float, Date)]) {
        self.type = type
        self.header = header
        self.title = title
        let filteredData = Array(data.sorted(by: { $0.1 < $1.1 }).prefix(31))
        self.data = filteredData

        if filteredData.isEmpty {
            self.average1 = .zero
            self.average2 = .zero
        } else {
            self.average1 = filteredData.dropLast(7).map(\.0).average()
            self.average2 = filteredData.suffix(7).map(\.0).average()
        }

        self.max = filteredData.map(\.0).max() ?? 0
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
    }

    var averagesText: some View {
        HStack {
            if type == .proceeds {
                UnitText(average1.toString(abbreviation: .intelligent, maxFractionDigits: 2), metric: Currency(rawValue: dataProvider.currency)?.symbol ?? "$")
                Spacer()
                UnitText(average2.toString(abbreviation: .intelligent, maxFractionDigits: 2), metric: Currency(rawValue: dataProvider.currency)?.symbol ?? "$")
            } else {
                UnitText(average1.toString(abbreviation: .intelligent, maxFractionDigits: 2), metricSymbol: type.systemImage)
                Spacer()
                UnitText(average2.toString(abbreviation: .intelligent, maxFractionDigits: 2), metricSymbol: type.systemImage)
            }
        }
        .foregroundColor(type.color)
    }

    var dateRanges: some View {
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

    var graph: some View {
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

    var line: some View {
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

    var firstDateIntervall: String {
        let days = self.data.dropLast(7).map(\.1)
        return formatDateRange(days)
    }
    var secondDateIntervall: String {
        let days = self.data.suffix(7).map(\.1)
        return formatDateRange(days)
    }

    func formatDateRange(_ days: [Date]) -> String {
        let sorted = days.sorted()
        guard let first = sorted.first, let last = sorted.last else { return "" }
        return first.toString(format: "dd. MMM") + "-" + last.toString(format: "dd. MMM")
    }
}

struct WeeklyAverageComparisonCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                WeeklyAverageComparisonCard(type: .downloads,
                                            header: true,
                                            title: "Your average earnings this week, are 3.7$ less.",
                                            data: ACData.exampleLargeSums.getRawData(for: .downloads, lastNDays: 30))
            }
            .secondaryBackground()

            CardSection {
                WeeklyAverageComparisonCard(type: .downloads,
                                            header: false,
                                            title: "Your average earnings this week, are 3.7$ less.",
                                            data: ACData.exampleLargeSums.getRawData(for: .downloads, lastNDays: 30))
            }
            .secondaryBackground()
            .preferredColorScheme(.dark)
        }
    }
}
