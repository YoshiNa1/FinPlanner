//
//  DataManager.swift
//  FinancePlanner
//
//  Created by Anastasiia on 23.10.2022.
//

import Foundation
import RealmSwift

class DataManager {
    let realm = try! Realm()
    
    var account: Account!
    var items : Results<Item>!
    
    public static var instance: DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    private init() {
        account = self.realm.objects(Account.self).first
        items = self.realm.objects(Item.self)
    }
    
    func create(account: Account) {
        try! self.realm.write({
            realm.add(account, update: .all)
        })
    }
    
    func updateAccount(withAmount amount: Double, isBalance: Bool) {
        try! self.realm.write({
            if(isBalance) {
                self.account.balance = amount
            } else {
                self.account.savings = amount
            }
        })
    }
    
    func updateAccount(withTransactionAmount amount: Double, isWithdraw: Bool) {
        try! self.realm.write({
            if(isWithdraw) {
                self.account.savings -= amount
                self.account.balance += amount
            } else {
                self.account.savings += amount
                self.account.balance -= amount
            }
        })
    }
    
    func add(item: Item) {
        try! self.realm.write({
            realm.add(item, update: .all)
        })
    }
    func delete(item: Item) {
        try! self.realm.write({
            realm.delete(item)
        })
    }
    func update(item: Item, withNewItem newItem: Item) {
        try! self.realm.write({
            item.name = newItem.name
            item.descrpt = newItem.descrpt
            item.amount = newItem.amount
            item.currency = newItem.currency
            item.category = newItem.category
        })
    }
}




// TODO: separate files for classes
class Account: Object {
    @objc dynamic var id: String = UUID().uuidString
//    @objc dynamic var userId: String = "" // User().id
    @objc dynamic var balance: Double = 0.0
    @objc dynamic var savings: Double = 0.0
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required override init() {
        super.init()
    }
    
    init(balance: Double,
         savings: Double) {
        self.balance = balance
        self.savings = savings
    }
}

class Item: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var type: String = ""
    @objc dynamic var isIncome: Bool = false
    @objc dynamic var name: String = ""
    @objc dynamic var descrpt: String = ""
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var currency: String = ""
    @objc dynamic var category: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required override init() {
        super.init()
    }
    
    init(isIncome: Bool,
         amount: Double) {
        self.date = Date()
        self.type = "savings"
        self.isIncome = isIncome
        self.name = "default string for savings type"
        self.descrpt = ""
        self.amount = amount
        self.currency = "default currency"
        self.category = "none"
    }
    
    init(type:String,
         name: String,
         description: String,
         amount: Double,
         currency: String,
         category: String) {
        self.date = Date()
        self.type = type
        self.name = name
        self.descrpt = description
        self.amount = amount
        self.currency = currency
        self.category = category
    }
}
