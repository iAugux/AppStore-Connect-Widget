//
//  DetailsOverview.swift
//  AC Widget
//
//  Created by Miká Kruschel on 05.01.22.
//

import SwiftUI

struct DetailsOverview: View {

    private let displayedInfoTypes: [InfoType] = [.downloads, .proceeds, .updates, .iap]

    var body: some View {
        ScrollView {
            ForEach(displayedInfoTypes, id: \.self) { infoType in
                DetailsRow(data: .exampleLargeSums, infoType: infoType)
                    .padding(.vertical, 10)
            }
        }
        .padding()
        .navigationTitle("DETAILS")
    }
}

struct DetailsOverview_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DetailsOverview()
        }
        .preferredColorScheme(.dark)
    }
}
