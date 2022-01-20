//
//  CardSection.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct CardSection<Content: View>: View {
    let content: Content
    let title: LocalizedStringKey?

    init(_ title: LocalizedStringKey? = nil, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.title = title
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title = title {
                HStack(alignment: .bottom) {
                    Text(title)
                        .font(.system(size: 22, weight: .semibold))
                    Spacer()
                }
                .padding(.bottom, 10)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 320))], spacing: 10) {
                content
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

struct CardSection_Previews: PreviewProvider {
    static var previews: some View {
            CardSection("Downloads") {
                ComparisonCard(type: .downloads,
                               header: true,
                               title: "Test",
                               primaryValue: 200,
                               primaryLabel: "This Week",
                               secondaryValue: 300,
                               secondaryLabel: "Last Week")
                    .frame(height: 255)
                ComparisonCard(type: .iap,
                               header: true,
                               title: "Test",
                               primaryValue: 300,
                               primaryLabel: "This Week",
                               secondaryValue: 200,
                               secondaryLabel: "Last Week")
                    .frame(height: 255)
            }
            .secondaryBackground()
    }
}
