//
//  DataManager.swift
//  FinancePlanner
//
//  Created by Anastasiia on 23.10.2022.
//

import Foundation
import RealmSwift
import Alamofire

class Connectivity {
    class func isConnected() -> Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

public class DataManager {
    private(set) var syncManager: SyncManager
    
//    private var user: User?
//    private var profile: Profile?
    
    var defaultCurrency: String {
        get { PreferencesStorage.shared.defaultCurrency?.name ?? ""}
    }
    
    public static var instance: DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    private init() {
        syncManager = SyncManager()
    }

  
// MARK: - Default Amount
    
    func getDefaultAmount(amount:Double, currency:String) -> Double {
        var _amount: Double = 0
        let amountText = convertAmountToDefault(amount:amount, currency:currency, style: .none)
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        let grade = formatter.number(from: amountText)
        if let doubleGrade = grade?.doubleValue {
            _amount = doubleGrade
        } else {
            _amount = Double(amountText) ?? 0
        }
        return _amount
    }
    
    func convertAmountToDefault(amount:Double, currency:String, style:NumberFormatter.Style = .decimal) -> String {
        let valCurr = ConvCurrency.currency(for: currency)
        let outCurr = ConvCurrency.currency(for: self.defaultCurrency)

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let defAmount = appDelegate.currencyConverter.convertAndFormat(amount, valueCurrency: valCurr, outputCurrency: outCurr, numberStyle: style, decimalPlaces: 2) ?? ""
            return defAmount
        }
        return ""
    }

// MARK: - Validation

    func validatePassword(_ str: String) -> Bool {
        return str.count > 7
    }
}
