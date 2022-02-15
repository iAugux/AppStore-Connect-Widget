//
//  UnitText.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import WidgetKit

struct UnitText: View {
    private let text: String
    private let infoType: InfoType
    private var fontSize: CGFloat = 30
    private var currencySymbol: String

    public init(_ text: String, infoType: InfoType, currencySymbol: String? = "") {
        assert(infoType != .proceeds || !(currencySymbol?.isEmpty ?? true), "Proceeds need a currencySymbol.")
        self.text = text
        self.infoType = infoType
        self.currencySymbol = currencySymbol ?? ""
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: fontSize*0.17) {
            HStack(alignment: .top, spacing: 0) {
                Text(text)

                if infoType == .proceeds && !currencySymbol.isEmpty {
                    Text(currencySymbol)
                        .font(.system(size: fontSize*0.5, weight: .semibold, design: .rounded) )
                        // .font(.system(size: fontSize*0.5))
                        .padding(.top, fontSize*0.1)
                        .foregroundColor(.secondary)
                        .hidePlaceholderRedacted()
                } else {
                    Image(systemName: infoType.systemImage)
                        .font(.system(size: fontSize*0.48, weight: .semibold, design: .default) )
                        .padding(.top, fontSize*0.1)
                        .foregroundColor(.secondary)
                        .hidePlaceholderRedacted()
                }
            }
            .font(.system(size: fontSize, weight: .semibold, design: .rounded))
            .minimumScaleFactor(0.8)
        }
        .lineLimit(1)
    }

    public func fontSize(_ fontSize: CGFloat) -> some View {
        var copy = self
        copy.fontSize = fontSize
        return copy
    }
}

struct UnitText_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            UnitText("45.3", infoType: .proceeds, currencySymbol: "€")
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            UnitText("4.8k", infoType: .downloads, currencySymbol: "€")
                .previewContext(WidgetPreviewContext(family: .systemSmall))

            VStack {
                HStack {
                    Spacer()
                    UnitText("253", infoType: .proceeds, currencySymbol: "€")
                        .fontSize(35)
                }
                Spacer()
            }
            .padding()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
