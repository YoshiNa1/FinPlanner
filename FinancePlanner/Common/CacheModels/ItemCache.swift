//
//  Item.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import RealmSwift

enum ItemType: String {
    case income = "income"
    case outcome = "outcome"
    case savings = "savings"
    case none = "none"
}

enum ItemCategoryType: String {
    case housing = "housing"
    case grocery = "grocery"
    case others = "other"
    case none = "none"
    
    static let all = [housing, grocery, others]
}

class ItemCache: Object {
    @objc dynamic var uuid: String = UUID().uuidString
    @objc dynamic var userUuid: String = "" // User().uuid
    @objc dynamic var date: Date = Date()
    @objc dynamic var isIncome: Bool = false
    @objc dynamic var name: String = ""
    @objc dynamic var descrpt: String = ""
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var currency: String = ""
    
    @objc dynamic var category: String = ""
    public dynamic var categoryType: ItemCategoryType {
        get {
            return ItemCategoryType(rawValue: self.category) ?? .none
        }
    }
    
    @objc dynamic var type: String = ""
    public dynamic var itemType: ItemType {
        get {
            return ItemType(rawValue: type) ?? .outcome
        }
    }
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(userUuid: String,
         isIncome: Bool,
         amount: Double,
         date: Date) {
        self.userUuid = userUuid
        self.date = date
        self.type = ItemType.savings.rawValue
        self.isIncome = isIncome
        self.name = "default string for savings type"
        self.descrpt = ""
        self.amount = amount
        self.currency = PreferencesStorage.shared.defaultCurrency?.name ?? ""
        self.category = ItemCategoryType.none.rawValue
    }
    
    init(userUuid: String,
         type:ItemType,
         name: String,
         description: String,
         amount: Double,
         currency: String,
         category:ItemCategoryType,
         date: Date) {
        self.userUuid = userUuid
        self.date = date
        self.type = type.rawValue
        self.name = name
        self.descrpt = description
        self.amount = amount
        self.currency = currency
        self.category = category.rawValue
    }
    
    init(userUuid: String,
         amount: Double,
         category: ItemCategoryType,
         date: Date) {
        self.userUuid = userUuid
        self.date = date
        self.amount = amount
        self.currency = PreferencesStorage.shared.defaultCurrency?.name ?? ""
        self.category = category.rawValue
    }
}
