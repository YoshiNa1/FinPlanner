//
//  Item.swift
//  FinancePlanner
//
//  Created by Anastasiia on 10.04.2023.
//

import Foundation

public enum ItemType: String {
    case income = "income"
    case outcome = "outcome"
    case savings = "savings"
    case none = "none"
}

public enum ItemCategoryType: String {
    case housing = "housing"
    case grocery = "grocery"
    case others = "other"
    case none = "none"
    
    static let all = [housing, grocery, others]
}

public struct Item {
    public var uuid: String = UUID().uuidString
    public var isIncome: Bool = false
    public var name: String = ""
    public var description: String = ""
    public var amount: Double
    public var currency: String
    public var created: Date
    public var categoryType: ItemCategoryType = .none
    public var itemType: ItemType = .none
    
    init(isIncome: Bool,
         amount: Double,
         date: Date) {
        self.created = date
        self.isIncome = isIncome
        self.name = "default string for savings type"
        self.amount = amount
        self.currency = PreferencesStorage.shared.defaultCurrency?.name ?? ""
    }
    
    init(type:ItemType,
         name: String,
         description: String,
         amount: Double,
         currency: String,
         category:ItemCategoryType,
         date: Date) {
        self.created = date
        self.itemType = type
        self.name = name
        self.description = description
        self.amount = amount
        self.currency = currency
        self.categoryType = category
    }
    
    init(amount: Double,
         category: ItemCategoryType,
         date: Date) {
        self.created = date
        self.amount = amount
        self.currency = PreferencesStorage.shared.defaultCurrency?.name ?? ""
        self.categoryType = category
    }
    
    
    init(neItem: NEItem) {
        self.uuid = neItem.uuid
        self.itemType = ItemType(rawValue: neItem.type.lowercased()) ?? .none
        self.isIncome = neItem.isIncome
        self.name = neItem.name
        self.description = neItem.description
        self.amount = neItem.amount
        self.currency = neItem.currency
        self.categoryType = ItemCategoryType(rawValue: neItem.category.lowercased()) ?? .none
        let dateString = neItem.createdAt
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime,
                                       .withDashSeparatorInDate,
                                       .withFullDate,
                                       .withFractionalSeconds,
                                       .withColonSeparatorInTimeZone]
        let date = dateFormatter.date(from:dateString) ?? Date()
        self.created = date
    }
    
    init(cache: ItemCache) {
        self.uuid = cache.uuid
        self.itemType = ItemType(rawValue: cache.type) ?? .none
        self.isIncome = cache.isIncome
        self.name = cache.name
        self.description = cache.descrpt
        self.amount = cache.amount
        self.currency = cache.currency
        self.categoryType = ItemCategoryType(rawValue: cache.category) ?? .none
        self.created = cache.date
    }
}
