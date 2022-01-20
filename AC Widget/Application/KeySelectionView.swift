//
//  KeySelectionView.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI

struct KeySelectionView: View {
    @EnvironmentObject var dataProvider: ACDataProvider

//    @AppStorage(UserDefaultsKey.homeSelectedKey, store: UserDefaults.shared) private var keyID: String = ""
//    @AppStorage(UserDefaultsKey.homeCurrency, store: UserDefaults.shared) private var currency: String = Currency.USD.rawValue

    var body: some View {
        Form {
            keySelection
            currencySelection
        }
        .navigationTitle("SELECT_KEY")
    }

    var keySelection: some View {
        Section(header: Label("API_KEY", systemImage: "key.fill")) {
            ForEach(dataProvider.apiKeysProvider.apiKeys) { key in
                Button(action: { dataProvider.keyID = key.id }, label: {
                    HStack {
                        Text("\(Image(systemName: "circle.fill"))")
                            .foregroundColor(key.color)
                        Text(key.name)
                        Spacer()
                        if key.id == dataProvider.selectedKey?.id {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(.accentColor)
                        }
                    }
                })
            }
        }
    }

    var currencySelection: some View {
        Section(header: Label("CURRENCY", systemImage: "dollarsign.circle.fill")) {
            NavigationLink(destination: CurrencyPicker(selection: dataProvider.$currency)) {
                HStack {
                Text("APP_CURRENCY")
                    Spacer()
                    CurrencySymbol(symbol: (Currency(rawValue: dataProvider.currency) ?? .USD).symbol)
                }
            }
        }
    }
}

struct CurrencySymbol: View {
    let symbol: String
    let strokeWeight: CGFloat = 1.5

    var body: some View {
        Text(symbol)
            .font(.system(.body, design: .rounded).weight(.semibold))
            .padding(.horizontal, 6)
            .overlay(
                Group {
                    if symbol.count == 1 {
                        Circle().stroke(.foreground, lineWidth: strokeWeight)
                    } else {
                        Capsule().stroke(.foreground, lineWidth: strokeWeight)
                    }
                }
            )
    }
}

struct KeySelectionView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Form {
                KeySelectionView().currencySelection
            }
        }
    }
}
