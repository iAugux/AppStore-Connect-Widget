//
//  DetailView.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 30.12.21.
//

import SwiftUI

struct DetailView: View {
    var type: InfoType

    var body: some View {
        HStack {
            Text("Hello: ")
            Label(type.stringKey, systemImage: type.systemImage)
        }
        .navigationTitle(type.stringKey)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(type: .downloads)
    }
}
