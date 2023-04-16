//
//  Profile.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import RealmSwift

class ProfileCache: Object {
    @objc dynamic var uuid: String = UUID().uuidString
    @objc dynamic var balance: Double = 0.0
    @objc dynamic var savings: Double = 0.0
    @objc dynamic var currency: String = "" // CHANGE EVERYTIME DEFAULT CURRENCY FROM SETTINGS CHANGED AND UPDATE BALANCE-SAVINGS
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(_ profile: Profile) {
        self.uuid = profile.uuid
        self.balance = profile.balance
        self.savings = profile.savings
        self.currency = profile.currency
    }
    
    init(neModel: NEProfile) {
        self.uuid = neModel.uuid
        self.balance = neModel.balance
        self.savings = neModel.savings
        self.currency = neModel.currency
    }
}
