//
//  ErrorCard.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct ErrorCard: View {
    @EnvironmentObject private var dataProvider: ACDataProvider
    let error: APIError

    var body: some View {
        VStack(spacing: 0) {
            header
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.top, .horizontal], 17)
                .padding(.bottom, 12)
                .background(Color.red)

            content
                .padding([.bottom, .horizontal], 17)
                .padding(.top, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.cardColor)
        }
        .cornerRadius(10)
    }

    private var header: some View {
        HStack {
            Label("Error", systemImage: "exclamationmark.circle.fill")
                .font(.subheadline.weight(.semibold))
            Spacer()
            Button(action: {
                dataProvider.error = nil
            }) {
                Image(systemName: "xmark")
                    .font(.subheadline.weight(.black))
            }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(error.userTitle)
                .font(.title2.weight(.semibold))

            Text(error.userDescription)
            Spacer()
        }
    }
}

struct ErrorCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSection {
                ErrorCard(error: .exceededLimit)
                ErrorCard(error: .invalidCredentials)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)
            
            CardSection {
                ErrorCard(error: .exceededLimit)
                ErrorCard(error: .invalidCredentials)
            }
            .secondaryBackground()
            .environmentObject(ACDataProvider.example)
            .preferredColorScheme(.dark)
        }
    }
}
