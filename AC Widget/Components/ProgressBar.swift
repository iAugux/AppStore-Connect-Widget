//
//  ProgressBar.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct ProgressBar: View {
    let value: CGFloat
    let color: Color

    init(value: Float, color: Color) {
        self.value = min(CGFloat(abs(value)), 1)
        self.color = color
    }

    init(value: Float, type: InfoType) {
        self.init(value: value, color: type.color)
    }

    var body: some View {
        GeometryReader { reading in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: reading.size.width * value)

                Rectangle()
                    .frame(maxWidth: .infinity)
                    .opacity(0.22)
            }
            .clipShape(Capsule())
            .foregroundColor(color)
        }
        .frame(height: 16)
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VStack(spacing: 10) {
                ProgressBar(value: 0.832, type: .downloads)
                ProgressBar(value: 0.36, type: .proceeds)
                ProgressBar(value: 0.732, type: .iap)
            }
            .padding()

            VStack(spacing: 10) {
                ProgressBar(value: 0.832, type: .downloads)
                ProgressBar(value: 0.36, type: .proceeds)
                ProgressBar(value: 0.732, type: .iap)
            }
            .padding()
            .preferredColorScheme(.dark)
        }
    }
}
