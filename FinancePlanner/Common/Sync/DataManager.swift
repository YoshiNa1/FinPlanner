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

    public func syncAllData(completion: @escaping (Error?) -> Void) {
        syncManager.syncAllData(completion: completion)
    }
    
    public func refreshSyncState() {
        syncManager.refreshSyncState()
    }
    
    public func getSyncStatus() -> SyncStatus {
        return syncManager.syncState
    }
    
// MARK: - Default Amount
    
    func getDefaultAmount(amount:Double, currency:String) -> Double {
        let amountText = convertAmountToDefault(amount:amount, currency:currency, style: .none)
        let _amount: Double = amountText.getDoubleFromText()
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
