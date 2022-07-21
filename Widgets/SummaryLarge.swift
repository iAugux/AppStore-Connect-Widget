//
//  SummaryLarge.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit
import BetterToStrings

struct SummaryLarge: View {
    @Environment(\.colorScheme) var colorScheme

    let data: ACData
    var color: Color = .accentColor
    let filteredApps: [ACApp]

    private var sortedApps: [ACApp] {
        data.apps.sorted {
            data.getRawData(for: .proceeds, lastNDays: 1, filteredApps: [$0]).map { $0.0 }.reduce(0, +) > data.getRawData(for: .proceeds, lastNDays: 1, filteredApps: [$1]).map { $0.0 }.reduce(0, +)
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                dateSection
                informationSection
                    .padding([.horizontal, .bottom], 14)
            }
            AppIconStack(apps: filteredApps)
                .padding(.top, 7.5)
                .padding(.trailing, 18)
        }
    }

    var dateSection: some View {
        Text(data.latestReportingDate())
            .font(.subheadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .background(Color.widgetSecondary)
    }

    var informationSection: some View {
        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 0) {
                downloadsSection
                Spacer()
                Spacer()
                proceedsSection
            }
            if filteredApps.count == 1 || data.apps.count <= 1 {
                countriesSection
            } else {
                appList
            }
        }
    }

    var downloadsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getRawData(for: .downloads, lastNDays: 1, filteredApps: filteredApps).toString(), metricSymbol: "square.and.arrow.down")
            GraphView(data.getRawData(for: .downloads, lastNDays: 30, filteredApps: filteredApps), color: color.readable(colorScheme: colorScheme))

            VStack(spacing: 0) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data
                                    .getRawData(for: .downloads, lastNDays: 7, filteredApps: filteredApps).toString(size: .compact))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data
                                    .getRawData(for: .downloads, lastNDays: 30, filteredApps: filteredApps).toString(size: .compact))
                DescribedValueView(descriptionString: data.latestReportingDate().toString(format: "MMMM").appending(":"),
                                   value: data.getRawData(for: .downloads, lastNDays: data.latestReportingDate().dateToMonthNumber(), filteredApps: filteredApps).toString(size: .compact))
            }
        }
    }

    var proceedsSection: some View {
        VStack(alignment: .leading, spacing: 5.0) {
            UnitText(data.getRawData(for: .proceeds, lastNDays: 1, filteredApps: filteredApps).toString(), metric: data.displayCurrency.symbol)
            GraphView(data.getRawData(for: .proceeds, lastNDays: 30, filteredApps: filteredApps), color: color.readable(colorScheme: colorScheme))

            VStack(spacing: 0) {
                DescribedValueView(description: "LAST_SEVEN_DAYS", value: data
                                    .getRawData(for: .proceeds, lastNDays: 7, filteredApps: filteredApps)
                                    .toString(size: .compact)
                                    .appending(data.displayCurrency.symbol))
                DescribedValueView(description: "LAST_THIRTY_DAYS", value: data
                                    .getRawData(for: .proceeds, lastNDays: 30, filteredApps: filteredApps)
                                    .toString(size: .compact)
                                    .appending(data.displayCurrency.symbol))
                DescribedValueView(descriptionString: data.latestReportingDate().toString(format: "MMMM").appending(":"),
                                   value: data
                                    .getRawData(for: .proceeds, lastNDays: data.latestReportingDate().dateToMonthNumber(), filteredApps: filteredApps)
                                    .toString(size: .compact)
                                    .appending(data.displayCurrency.symbol))
            }
        }
    }

    var countriesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TOP_COUNTRIES")
                .font(.system(size: 18, weight: .medium, design: .default))
                .padding(.bottom, 3)

            DescribedValueView(description: countryName(placement: 0), value: countryProceeds(placement: 0))
            DescribedValueView(description: countryName(placement: 1), value: countryProceeds(placement: 1))
            DescribedValueView(description: countryName(placement: 2), value: countryProceeds(placement: 2))
        }
    }

    var fewApps: Bool {
        filteredApps.count == 2 || (filteredApps.count == 0 && data.apps.count == 2)
    }

    var appList: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: fewApps ? 300 : 100))], spacing: 8) {
            ForEach((filteredApps.isEmpty ? sortedApps : filteredApps).prefix(4)) { app in
                Card(alignment: .leading, spacing: 3, innerPadding: 8, color: .cardColor) {
                    HStack(spacing: 4) {
                        Group {
                            if let data = app.artwork60ImgData, let uiImg = UIImage(data: data) {
                                Image(uiImage: uiImg)
                                    .resizable()
                            } else {
                                Rectangle().foregroundColor(.secondary)
                            }
                        }
                        .frame(width: 15, height: 15)
                        .cornerRadius(4)

                        Text(app.name)
                            .lineLimit(1)
                        Spacer()
                    }

                    HStack(alignment: .bottom) {
                        UnitText(data.getRawData(for: .downloads, lastNDays: 1, filteredApps: [app]).toString(), metricSymbol: InfoType.downloads.systemImage)
                            .fontSize(fewApps ? 25 : 19)
                        Spacer()
                        UnitText(data.getRawData(for: .proceeds, lastNDays: 1, filteredApps: [app]).toString(), metric: data.displayCurrency.symbol)
                            .fontSize(fewApps ? 25 : 19)
                        if fewApps {
                            Spacer()
                            UnitText(data.getRawData(for: .iap, lastNDays: 1, filteredApps: [app]).toString(), metricSymbol: InfoType.iap.systemImage)
                                .fontSize(25)
                        }
                    }
                }
            }
        }
    }

    private func countryName(placement: Int) -> LocalizedStringKey {
        let countries = data.getCountries(.proceeds, lastNDays: 30, filteredApps: filteredApps).sorted(by: { $0.1 > $1.1 })
        if placement < countries.count {
            return LocalizedStringKey(countries[placement].0.countryCodeToName())
        }
        return ""
    }

    private func countryProceeds(placement: Int) -> String {
        let countries = data.getCountries(.proceeds, lastNDays: 30, filteredApps: filteredApps).sorted(by: { $0.1 > $1.1 })
        if placement < countries.count {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 1
            let number = NSNumber(value: countries[placement].1)
            if let string = nf.string(from: number) {
                return string.appending(data.displayCurrency.symbol)
            }
        }
        return ""
    }
}

struct SummaryLarge_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SummaryLarge(data: ACData.example, filteredApps: [ACApp.mockApp])
                .previewContext(WidgetPreviewContext(family: .systemLarge))

            SummaryLarge(data: ACData.example, filteredApps: [])
                .background(Color.widgetBackground)
                .preferredColorScheme(.dark)
                .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
