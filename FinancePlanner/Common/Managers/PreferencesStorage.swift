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
        get { self.currencies.first(where: {$0.isDefault}) }
    }
    
    var currencies: Array<Currency> {
        set {
            do {
                let encoder = JSONEncoder()
                let data = try encoder.encode(newValue)
                storage.set(data, forKey: "currencies")
                DataManager.instance.updateProfile(withCurrency: newValue.first(where: {$0.isDefault})?.name ?? ""){ _, _ in }
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
    
    var email: String {
        set {
            storage.set(newValue, forKey: "email")
        }
        get {
            return storage.string(forKey: "email") ?? ""
        }
    }
    
    var accessToken: String {
        set {
            storage.set(newValue, forKey: "access_token")
        }
        get {
            return storage.string(forKey: "access_token") ?? ""
        }
    }
    
    public func clearSettings() {
        currencies.removeAll()
        email = ""
        accessToken = ""
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
    
    init(convCurrency: ConvCurrency) {
        self.name = convCurrency.rawValue
    }
    
    func getConvCurrency() -> ConvCurrency {
        return ConvCurrency(rawValue: self.name) ?? .none
    }
}
