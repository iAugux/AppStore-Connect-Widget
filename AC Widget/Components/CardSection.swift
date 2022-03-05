//
//  CardSection.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct CardSection<Content: View>: View {
    let content: Content
    let title: String?

    init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
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
                    .frame(height: 280)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

struct CardSection_Previews: PreviewProvider {
    static var previews: some View {
            CardSection("Downloads") {
                WeeklyAverageCard(type: .downloads, header: true)
                WeeklyAverageCard(type: .downloads, header: true)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)
    }
}
