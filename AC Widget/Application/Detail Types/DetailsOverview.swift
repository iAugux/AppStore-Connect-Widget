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
            if let data = dataProvider.data {
                ForEach(displayedInfoTypes, id: \.self) { infoType in
                    NavigationLink(destination: {
                        switch infoType {
                        case .downloads:
                            DownloadsView()
                        default:
                            Text("TODO")
                        }
                    }, label: {
                        DetailsRow(data: data, infoType: infoType)
                            .padding(.vertical, 10)
                    })
                        .buttonStyle(.plain)
                }
                .padding(.horizontal)
            } else {
                loadingIndicator
            }
        }
        .navigationTitle("DETAILS")
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
