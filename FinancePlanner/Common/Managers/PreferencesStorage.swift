//
//  UserPreferences .swift
//  FinancePlanner
//
//  Created by Anastasiia on 30.10.2022.
//

import Foundation

class PreferencesStorage {
    let storage = UserDefaults.standard
    static let shared = PreferencesStorage()
    private init() {}
    
    var defaultCurrency: Currency? {
        get { PreferencesStorage.shared.currencies.first(where: {$0.isDefault}) }
    }
    
    var currencies: Array<Currency> {
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                storage.set(data, forKey: "currencies")
            } catch {
                print(error)
            }
        }
        get {
            if let data = storage.data(forKey: "currencies") {
                do {
                    let decoder = JSONDecoder()
                    let currencies = try decoder.decode([Currency].self, from: data)
                    return currencies
                } catch {
                    print(error)
                }
            }
            return []
        }
    }
    
    public func clearSettings() {
        currencies = []
    }
}

// TODO: separate files for classes
class Currency : Codable {
    var name: String = ""
    var isDefault: Bool = false
    
    init(name: String,
         isDefault: Bool = false) {
        self.name = name
        self.isDefault = isDefault
    }
}
