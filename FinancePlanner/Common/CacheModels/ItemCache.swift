//
//  Item.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import RealmSwift

class ItemCache: Object {
    @objc dynamic var uuid: String = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var isIncome: Bool = false
    @objc dynamic var name: String = ""
    @objc dynamic var descrpt: String = ""
    @objc dynamic var amount: Double = 0.0
    @objc dynamic var currency: String = ""
    @objc dynamic var category: String = ""
    @objc dynamic var type: String = ""
    
    @objc dynamic var isActive: Bool = true
    
    override class func primaryKey() -> String? {
        return "uuid"
    }
    
    required override init() {
        super.init()
    }
    
    init(neModel: NEItem) {
        self.uuid = neModel.uuid
        self.type = neModel.type.lowercased()
        self.isIncome = neModel.isIncome
        self.name = neModel.name
        self.descrpt = neModel.description
        self.amount = neModel.amount
        self.currency = neModel.currency
        self.category = neModel.category.lowercased()
        let dateString = neModel.createdAt
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime,
                                       .withDashSeparatorInDate,
                                       .withFullDate,
                                       .withFractionalSeconds,
                                       .withColonSeparatorInTimeZone]
        let date = dateFormatter.date(from:dateString) ?? Date()
        self.date = date
    }
    
    init(_ model: Item) {
        self.uuid = model.uuid
        self.type = model.itemType.rawValue
        self.isIncome = model.isIncome
        self.name = model.name
        self.descrpt = model.description
        self.amount = model.amount
        self.currency = model.currency
        self.category = model.categoryType.rawValue
        self.date = model.created
    }
}
