//
//  DetailsOverview.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct DetailsOverview: View {
    @EnvironmentObject var dataProvider: ACDataProvider

    private let displayedInfoTypes: [InfoType] = [.downloads, .proceeds, .updates, .iap]

    var body: some View {
        RefreshableScrollView(onRefresh: {
            await dataProvider.refreshData(useMemoization: false)
        }) {
            if dataProvider.data != nil {
                ForEach(displayedInfoTypes, id: \.self) { infoType in
                    NavigationLink(destination: {
                        DetailView(type: infoType, secondaryType: infoType.associatedType)
                    }, label: {
                        DetailsRow(infoType: infoType)
                            .padding(.vertical, 10)
                    })
                        .buttonStyle(.plain)
                }
                .padding(.horizontal)
            } else {
                loadingIndicator
            }
        }
        .navigationTitle("Details")
        .secondaryBackground()
    }

    var loadingIndicator: some View {
        HStack(spacing: 10) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())

            Text("LOADING_DATA")
                .foregroundColor(.gray)
                .italic()
        }
        .padding(.top, 25)
        .frame(maxWidth: .infinity)
    }
}

struct DetailsOverview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailsOverview()
        }
        .preferredColorScheme(.dark)
        .environmentObject(ACDataProvider.example)
    }
}
