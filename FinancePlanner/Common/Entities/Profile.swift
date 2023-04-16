//
//  Profile.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation

public struct Profile {
    public var uuid: String = UUID().uuidString
    public var balance: Double
    public var savings: Double
    public var currency: String
    
    init(balance: Double,
         savings: Double,
         currency: String) {
        self.balance = balance
        self.savings = savings
        self.currency = currency
    }
    
    init(cache: ProfileCache) {
        self.uuid = cache.uuid
        self.balance = cache.balance
        self.savings = cache.savings
        self.currency = cache.currency
    }
    
    init(neProfile: NEProfile) {
        self.uuid = neProfile.uuid
        self.balance = neProfile.balance
        self.savings = neProfile.savings
        self.currency = neProfile.currency
    }
}
