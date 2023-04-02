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
    @objc dynamic var userUuid: String = ""
    @objc dynamic var balance: Double = 0.0
    @objc dynamic var savings: Double = 0.0
    @objc dynamic var currency: String = "" // CHANGE EVERYTIME DEFAULT CURRENCY FROM SETTINGS CHANGED AND UPDATE BALANCE-SAVINGS
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(userUuid: String,
         balance: Double,
         savings: Double,
         currency: String) {
        self.userUuid = userUuid
        self.balance = balance
        self.savings = savings
        self.currency = currency
    }
}
