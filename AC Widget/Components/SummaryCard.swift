//
//  SummaryCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct SummaryCard: View {
    init(data: ACData, type: InfoType, header: Bool) {
        self.data = data
        self.type = type
        self.header = header

        rawData = data.getRawData(for: type, lastNDays: 30)
        let copy = rawData.map { $0.0 }
        let max: Float = copy.max() ?? 1
        graphData = copy.map { CGFloat($0 / max) }
    }

    private var data: ACData
    private var rawData: [RawDataPoint]
    private var graphData: [CGFloat]

    private var currencySymbol: String {
        switch type {
        case .proceeds:
            return data.displayCurrency.symbol
        default:
            return ""
        }
    }
    @State private var currentIndex: Int?

    let type: InfoType
    let header: Bool

    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: 10) {
                if header {
                    Label(type.stringKey, systemImage: type.systemImage)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(type.color)
                }
                topSection
                graphSection
                bottomSection
            }
        }
    }

    // MARK: Top
    var topSection: some View {
        HStack(alignment: .top) {
            if let index = currentIndex {
                Text(getGraphDataPoint(index).1.toString(format: "dd. MMM.", smartConversion: true))
                    .font(.system(size: 20))
                Spacer()
                UnitText(getGraphDataPoint(index).0.toString(abbreviation: .intelligent, maxFractionDigits: 2), infoType: type, currencySymbol: currencySymbol)
            } else {
                Text(data.latestReportingDate())
                    .font(.system(size: 20))
                Spacer()
                UnitText(data.getRawData(for: type, lastNDays: 1).toString(), infoType: type, currencySymbol: currencySymbol)
            }
        }
    }

    private func getGraphDataPoint(_ index: Int) -> RawDataPoint {
        if index >= rawData.count {
            return rawData.last ?? (0, Date(timeIntervalSince1970: 0))
        }
        if index < 0 {
            return rawData.first ?? (0, Date(timeIntervalSince1970: 0))
        }
        return rawData[index]
    }

    // MARK: Graph
    var graphSection: some View {
        Group {
            if !graphData.isEmpty {
                GeometryReader { reading in
                    HStack(alignment: .bottom, spacing: 0) {
                        ForEach(graphData.indices, id: \.self) { i in
                            Capsule()
                                .frame(width: (reading.size.width/CGFloat(graphData.count))*0.7, height: reading.size.height * getGraphHeight(i))
                                .foregroundColor(getGraphColor(i))
                                .opacity(currentIndex == i ? 0.7 : 1)

                            if i != graphData.count-1 {
                                Spacer()
                                    .frame(minWidth: 0)
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .highPriorityGesture(DragGesture(minimumDistance: 20)
                        .onChanged({ value in
                            let newIndex = Int((value.location.x/reading.size.width) * CGFloat(graphData.count))
                            if newIndex != currentIndex && newIndex < rawData.count && newIndex >= 0 {
                                currentIndex = newIndex
                                UISelectionFeedbackGenerator()
                                    .selectionChanged()
                            }
                        })
                            .onEnded({ _ in
                                withAnimation(Animation.easeOut(duration: 0.2)) {
                                    currentIndex = nil
                                }
                            })
                    )
                }
            } else {
                Text("NO_DATA")
                    .foregroundColor(.gray)
                    .italic()
            }
        }
    }

    private func getGraphHeight(_ i: Int) -> CGFloat {
        if i < graphData.count && graphData[i] > 0 {
            return graphData[i]
        }
        if i < graphData.count && graphData[i] < 0 {
            return abs(graphData[i])
        }
        return 0.01
    }

    private func getGraphColor(_ i: Int) -> Color {
        var result: Color = .gray
        if i < graphData.count && graphData[i] > 0 {
            result = type.color
        } else if i < graphData.count && graphData[i] < 0 {
            result = .red
        }
        return result
    }

    // MARK: Bottom
    var bottomSection: some View {
        VStack {
            HStack(alignment: .bottom) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data.getRawData(for: type, lastNDays: 7).toString(size: .compact).appending(currencySymbol))
                Spacer()
                    .frame(width: 40)
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data.getRawData(for: type, lastNDays: 30).toString(size: .compact).appending(currencySymbol))
            }

            HStack(alignment: .bottom) {
                DescribedValueView(description: "CHANGE_PERCENT", value: data.getChange(type).appending("%"))
                Spacer()
                    .frame(width: 40)
                DescribedValueView(descriptionString: data.latestReportingDate().toString(format: "MMMM").appending(":"),
                                   value: data.getRawData(for: type, lastNDays: data.latestReportingDate().dateToMonthNumber()).toString(size: .compact).appending(currencySymbol))
            }
        }
    }
}

struct SummaryCard_Previews: PreviewProvider {
    static var previews: some View {
        CardSection {
            SummaryCard(data: .example, type: .downloads, header: true)
            SummaryCard(data: .example, type: .proceeds, header: false)
        }
        .secondaryBackground()
        .environmentObject(ACDataProvider.example)
    }
}
