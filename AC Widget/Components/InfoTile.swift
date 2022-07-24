//
//  InfoTile.swift
//  AC Widget by NO-COMMENT
//

import BetterToStrings
import Kingfisher
import SwiftUI

struct InfoTile: View {
    private var description: LocalizedStringKey
    private var data: ACData
    private var type: InfoType
    private var currencySymbol: String {
        switch type {
        case .proceeds:
            return data.displayCurrency.symbol
        default:
            return ""
        }
    }

    @State private var isFlipped: Bool = false
    @State private var interval: Int = 0
    private var lastNDays: Int {
        switch interval {
        case 1:
            return 7
        case 2:
            return 30
        case 3:
            return data.latestReportingDate().dateToMonthNumber()
        default:
            return 1
        }
    }

    init(description: LocalizedStringKey, data: ACData, type: InfoType) {
        self.description = description
        self.data = data
        self.type = type
    }

    var body: some View {
        Card {
            if isFlipped {
                backside
                    .rotation3DEffect(Angle(degrees: 180), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
            } else {
                InfoTileFront(description: description, data: data, type: type)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            self.isFlipped.toggle()
                        }
                    }
            }
        }
        .frame(height: 250)
        .rotation3DEffect(self.isFlipped ? Angle(degrees: 180) : Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
        .frame(height: 250)
    }

    var backside: some View {
        VStack {
            Picker("SELECT_INTERVAL", selection: $interval) {
                Text("1D").tag(0)
                Text("7D").tag(1)
                Text("30D").tag(2)
                Text(data.latestReportingDate().toString(format: "MMM")).tag(3)
            }
            .pickerStyle(.segmented)
            ScrollView(showsIndicators: false) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 8) {
                    ForEach(infoApps) { app in
                        appDetail(for: app)
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    self.isFlipped.toggle()
                }
            }
        }
    }

    private var infoApps: [InfoApp] {
        data.apps
            .map {
                .init(app: $0, rawData: data.getRawData(for: type, lastNDays: lastNDays, filteredApps: [$0]))
            }
            .sorted {
                $0.rawData.map { data in data.0 }.reduce(0, +) > $1.rawData.map { data in data.0 }.reduce(0, +)
            }
    }

    @ViewBuilder
    private func appDetail(for infoApp: InfoApp) -> some View {
        Card(alignment: .leading, spacing: 5, innerPadding: 10, color: .secondaryCardColor) {
            HStack(spacing: 4) {
                KFImage(URL(string: infoApp.app.artworkUrl60))
                    .placeholder {
                        Rectangle().foregroundColor(.secondary)
                    }
                    .resizable()
                    .frame(width: 15, height: 15)
                    .cornerRadius(4)

                Text(infoApp.app.name)
                    .lineLimit(1)
                Spacer()
            }

            if currencySymbol.isEmpty {
                UnitText(infoApp.rawData.toString(), metricSymbol: type.systemImage)
            } else {
                UnitText(infoApp.rawData.toString(), metric: currencySymbol)
            }
        }
    }

    private struct InfoApp: Identifiable {
        var id: String {
            app.id
        }

        let app: ACApp
        let rawData: [(Float, Date)]
    }
}

struct InfoTile_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 8) {
            InfoTile(description: "PROCEEDS", data: ACData.example, type: .proceeds)
            InfoTile(description: "PROCEEDS", data: ACData.example, type: .proceeds)
        }.padding()
    }
}
