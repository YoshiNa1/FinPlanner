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
    
    let defaultCurrency = PreferencesStorage.shared.currencies.first(where: {$0.isDefault})?.name ?? ""
    
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
 
// Account
    func create(account: Account) {
        try! self.realm.write({
            realm.add(account, update: .all)
        })
    }
    
    func updateAccount(withAmount amount: Double, currency: String, isBalance: Bool) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: currency)
        try! self.realm.write({
            if(isBalance) {
                self.account.balance = defAmount
            } else {
                self.account.savings = defAmount
            }
        })
    }
    
    func updateAccount(withTransactionAmount amount: Double, currency: String, isWithdraw: Bool) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: currency)
        try! self.realm.write({
            if(isWithdraw) {
                self.account.savings -= defAmount
                self.account.balance += defAmount
            } else {
                self.account.savings += defAmount
                self.account.balance -= defAmount
            }
        })
    }
   
    func updateAccount(withItem item: Item, amount: Double, isRemoval: Bool = false) {
        let defAmount = self.getDefaultAmount(amount: amount, currency: item.currency)
        try! self.realm.write({
            if(isRemoval) {
                if(item.type == "outcome") {
                    self.account.balance += defAmount
                }
                if(item.type == "income") {
                    self.account.balance -= defAmount
                }
            } else {
                if(item.type == "outcome") {
                    self.account.balance -= defAmount
                }
                if(item.type == "income") {
                    self.account.balance += defAmount
                }
            }
        })
    }

// Item
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
    
// Default Amount
    private func getDefaultAmount(amount:Double, currency:String) -> Double {
        var _amount: Double = 0
        let amountText = convertAmountToDefault(amount:amount, currency:currency)
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
    
    func convertAmountToDefault(amount:Double, currency:String) -> String {
        let valCurr = ConvCurrency.currency(for: currency)
        let outCurr = ConvCurrency.currency(for: self.defaultCurrency)

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let defAmount = appDelegate.currencyConverter.convertAndFormat(amount, valueCurrency: valCurr, outputCurrency: outCurr, numberStyle: .decimal, decimalPlaces: 2) ?? ""
            return defAmount
        }
        return ""
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
