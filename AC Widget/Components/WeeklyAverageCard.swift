//
//  WeeklyAverageCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import BetterToStrings

struct WeeklyAverageCard: View {
    let type: InfoType
    let header: Bool
    let title: LocalizedStringKey
    let data: [(Float, Date)]
    let average: Float
    let max: Float

    init(type: InfoType, header: Bool, title: LocalizedStringKey, data: [(Float, Date)]) {
        self.type = type
        self.header = header
        self.title = title
        let filteredData = Array(data.sorted(by: { $0.1 < $1.1 }).prefix(7))
        self.data = filteredData
        self.average = filteredData.map({ $0.0 }).reduce(0, +) / Float(filteredData.count)
        self.max = filteredData.map({ $0.0 }).max() ?? 0
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
                    ZStack(alignment: .top) {
                        graph
                        line
                    }
                } else {
                    Text("NO_DATA")
                }
            }
        }
    }

    var graph: some View {
        GeometryReader { val in
            HStack(alignment: .bottom) {
                Spacer()
                ForEach(data, id: \.1) { (value, date) in
                    VStack {
                        RoundedRectangle(cornerRadius: 4)
                            .frame(width: val.size.width/20, height: val.size.height * CGFloat(value/max) - 25)
                        Text(date.toString(format: "EEEEE"))
                    }
                    .foregroundColor(Color(uiColor: .systemGray4))
                }
            }
            .padding(.horizontal)
        }
    }

    var line: some View {
        GeometryReader { val in
            Capsule()
                .foregroundColor(type.color)
                .frame(height: 6)
                .padding(.top, val.size.height - (val.size.height * CGFloat(average/max)) - 3)
                .overlay {
                    text
                        .padding(.top, val.size.height - (val.size.height * CGFloat(average/max)) + 8)
                }
        }
    }

    var text: some View {
        HStack {
            VStack(alignment: .leading, spacing: 12) {
                (Text("Avg. ")+Text(type.stringKey))
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color(uiColor: .systemGray4))

                UnitText(average.toString(abbreviation: .intelligent, maxFractionDigits: 1), metricSymbol: type.systemImage)
            }
            .padding(.leading, 10)
            Spacer()
        }
    }
}

struct WeeklyAverageCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeeklyAverageCard(type: .downloads,
                              header: true,
                              title: "You had an average of 78 Downloads this week.",
                              data: [
                                (0, Date.init(timeIntervalSinceNow: 0)),
                                (1500, Date.init(timeIntervalSinceNow: -1 * 86400)),
                                (0, Date.init(timeIntervalSinceNow: -2 * 86400)),
                                (0, Date.init(timeIntervalSinceNow: -3 * 86400)),
                                (500, Date.init(timeIntervalSinceNow: -4 * 86400)),
                                (250, Date.init(timeIntervalSinceNow: -5 * 86400)),
                                (300, Date.init(timeIntervalSinceNow: -6 * 86400)),
                              ])
                .frame(maxHeight: 300)
                .padding()
                .background(Color(uiColor: .secondarySystemBackground))

            WeeklyAverageCard(type: .downloads,
                              header: false,
                              title: "You had an average of 78 Downloads this week.",
                              data: [
                                (83, Date.init(timeIntervalSinceNow: 0)),
                                (145, Date.init(timeIntervalSinceNow: -1 * 86400)),
                                (68, Date.init(timeIntervalSinceNow: -2 * 86400)),
                                (111, Date.init(timeIntervalSinceNow: -3 * 86400)),
                                (83, Date.init(timeIntervalSinceNow: -4 * 86400)),
                                (76, Date.init(timeIntervalSinceNow: -5 * 86400)),
                                (79, Date.init(timeIntervalSinceNow: -6 * 86400)),
                              ])
                .frame(maxHeight: 300)
                .padding()
                .preferredColorScheme(.dark)
        }
    }
}
