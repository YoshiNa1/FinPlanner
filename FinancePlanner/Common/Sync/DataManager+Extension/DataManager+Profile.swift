//
//  DataManager+Profile.swift
//  FinancePlanner
//
//  Created by Anastasiia on 11.04.2023.
//

import Foundation

extension DataManager {
    
    func getProfile(completion: @escaping (Profile?, Error?) -> Void) {
        syncManager.getProfile(completion: completion)
    }
    
    func createProfile(with balance: Double, _ balanceCurrency: String, and savings: Double, _ savingsCurrency: String, completion: @escaping (Profile?, Error?) -> Void) {
        let defBalanceAmount = self.getDefaultAmount(amount: balance, currency: balanceCurrency)
        let defSavingsAmount = self.getDefaultAmount(amount: savings, currency: savingsCurrency)
        let profile = Profile(balance: defBalanceAmount, savings: defSavingsAmount, currency: self.defaultCurrency)
        syncManager.doProfileAction(.createAction, profile: profile, completion: completion)
    }
    
    func updateProfile(withAmount amount: Double, currency: String, isBalance: Bool, completion: @escaping (Profile?, Error?) -> Void) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: currency)
        self.getProfile { profile, error in
            if var profile = profile {
                if(isBalance) {
                    profile.balance = defAmount
                } else {
                    profile.savings = defAmount
                }
                self.syncManager.doProfileAction(.editAction, profile: profile, completion: completion)
            }
        }
    }
    
    func updateProfile(withTransactionAmount amount: Double, currency: String, isWithdraw: Bool, completion: @escaping (Profile?, Error?) -> Void) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: currency)
        self.getProfile { profile, error in
            if var profile = profile {
                if(isWithdraw) {
                    profile.savings -= defAmount
                    profile.balance += defAmount
                } else {
                    profile.savings += defAmount
                    profile.balance -= defAmount
                }
                self.syncManager.doProfileAction(.editAction, profile: profile, completion: completion)
            }
        }
    }
   
    func updateProfile(withItem item: Item, amount: Double, isRemoval: Bool = false, completion: @escaping (Profile?, Error?) -> Void) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: item.currency)
        self.getProfile { profile, error in
            if var profile = profile {
                if(isRemoval) {
                    if(item.itemType == .outcome) {
                        profile.balance += defAmount
                    }
                    if(item.itemType == .income) {
                        profile.balance -= defAmount
                    }
                } else {
                    if(item.itemType == .outcome) {
                        profile.balance -= defAmount
                    }
                    if(item.itemType == .income) {
                        profile.balance += defAmount
                    }
                }
                self.syncManager.doProfileAction(.editAction, profile: profile, completion: completion)
            }
        }
    }
    
    func updateProfile(withCurrency newDefaultCurrency: String, completion: @escaping (Profile?, Error?) -> Void) {
        self.getProfile { profile, error in
            if var profile = profile {
                let oldDefaultCurrency = profile.currency
                profile.currency = newDefaultCurrency
                
                profile.balance = self.getDefaultAmount(amount: profile.balance, currency: oldDefaultCurrency)
                profile.savings = self.getDefaultAmount(amount: profile.savings, currency: oldDefaultCurrency)
                
                self.syncManager.doProfileAction(.editAction, profile: profile, completion: completion)
            }
        }
    }
}
