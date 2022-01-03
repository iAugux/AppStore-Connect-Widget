//
//  DetailsRow.swift
//  AC Widget
//
//  Created by Miká Kruschel on 03.01.22.
//

import SwiftUI
// infotype
struct DetailsRow: View {
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                    Text("Downloads")
                }
                .font(.caption.bold())

                Spacer()

                HStack {
                    Text("Yesterday")
                    Image(systemName: "chevron.right")
                }.font(.caption)
            }

            Spacer(minLength: 5)

            HStack {
                UnitText("280", metricSymbol: "square.and.arrow.down")
                Spacer(minLength: 50)
                GraphView(ACData.example.getRawData(for: .downloads, lastNDays: 30), color: .pink)
            }
            .frame(minHeight: 50)
        }
        .padding(5)
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct DetailsRow_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(ColorScheme.allCases, id: \.self) { scheme in
            ZStack {
                Color.secondary
                DetailsRow()
                    .padding()
                    .frame(height: 150)
            }
//            .previewLayout(.fixed(width: 300, height: 100))
            .preferredColorScheme(scheme)
        }
    }
}
