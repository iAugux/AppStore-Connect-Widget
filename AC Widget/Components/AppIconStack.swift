//
//  AppIconStack.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import Kingfisher

struct AppIconStack: View {
    var apps: [ACApp]

    var maxAppCount: Int = 4

    private var showAppCount: Int {
        if apps.count <= maxAppCount {
            return apps.count
        }
        return maxAppCount - 1
    }

    var body: some View {
        ZStack {
            ForEach(0..<showAppCount, id: \.self) { index in
                KFImage(URL(string: apps[index].artworkUrl60))
                    .placeholder {
                        Rectangle()
                            .foregroundColor(.secondary)
                    }
                    .resizable()
                    .frame(width: 15, height: 15)
                    .cornerRadius(3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .stroke(Color.secondaryCardColor, lineWidth: 0.3)
                    )
                    .padding(.leading, 12 * CGFloat(index))
            }

            if apps.count > maxAppCount {
                ZStack {
                    Image(systemName: "app.fill")
                        .foregroundColor(.secondaryCardColor)
                    Text("+\(apps.count-3)")
                        .font(.system(size: 8))
                        .minimumScaleFactor(0.5)
                }
                .frame(width: 15, height: 15)
                .padding(.leading, 36)
            }
        }
    }
}

struct AppIconStack_Previews: PreviewProvider {
    static var previews: some View {
        AppIconStack(apps: [.mockApp, .mockApp, .mockApp, .mockApp, .mockApp])
    }
}
