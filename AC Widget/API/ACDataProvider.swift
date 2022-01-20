//
//  ACDataProvider.swift
//  AC Widget by NO-COMMENT
//

import SwiftUI
import Combine

class ACDataProvider: ObservableObject {
    @Published public var data: ACData?
    @Published public var error: APIError?
    @Published public var apiKeysProvider: APIKeyProvider

    @AppStorage(UserDefaultsKey.homeSelectedKey, store: UserDefaults.shared) public var keyID: String = "" {
        didSet { refresh() }
    }
    @AppStorage(UserDefaultsKey.homeCurrency, store: UserDefaults.shared) public var currency: String = Currency.USD.rawValue {
        didSet { refresh() }
    }

    public var selectedKey: APIKey? {
        return apiKeysProvider.getApiKey(apiKeyId: keyID) ?? apiKeysProvider.apiKeys.first
    }

    init() {
        data = nil
        error = nil
        apiKeysProvider = APIKeyProvider()
    }

    private func refresh() {
        data = nil
        error = nil
        Task {
            await refreshData()
        }
    }

    public func refreshData(useMemoization: Bool = true) async {
        guard let apiKey = selectedKey else {
            data = nil
            error = .unknown
            return
        }
        let api = await AppStoreConnectApi(apiKey: apiKey)
        do {
            data = try await api.getData(currency: Currency(rawValue: currency), useMemoization: useMemoization)
        } catch let err as APIError {
            self.error = err
        } catch {}
    }
}

fileprivate extension UserDefaultsKey {
    static let homeSelectedKey = "homeSelectedKey"
    static let homeCurrency = "homeCurrency"
}

extension ACDataProvider {
    static let example: ACDataProvider = {
        let provider = ACDataProvider()
        provider.data = .example
        return provider
    }()
}
