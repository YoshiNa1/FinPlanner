//
//  NEItem.swift
//  FinancePlanner
//
//  Created by Anastasiia on 02.04.2023.
//

import Foundation
import ObjectMapper

struct NEItem {
    let uuid: String
    let type: String
    let isIncome: Bool
    let name: String
    let description: String
    let category: String
    let amount: Double
    let currency: String
    let createdAt: String
    
    init(cache: ItemCache) {
        self.uuid = cache.uuid
        self.type = cache.type.uppercased()
        self.isIncome = cache.isIncome
        self.name = cache.name
        self.description = cache.descrpt
        self.amount = cache.amount
        self.currency = cache.currency
        self.category = cache.category.uppercased()
        let date = cache.date
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from:date)
        self.createdAt = dateString
    }
    
    init(_ model: Item) {
        self.uuid = model.uuid
        self.type = model.itemType.rawValue.uppercased()
        self.isIncome = model.isIncome
        self.name = model.name
        self.description = model.description
        self.amount = model.amount
        self.currency = model.currency
        self.category = model.categoryType.rawValue.uppercased()
        let date = model.created
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from:date)
        self.createdAt = dateString
    }
}

extension NEItem: ImmutableMappable {
    enum CodingKeys: String {
        case uuid
        case type
        case isIncome
        case name
        case description
        case category
        case amount
        case currency
        case createdAt
    }
    
    public init(map: Map) throws {
        uuid = try map.value(CodingKeys.uuid.rawValue)
        type = try map.value(CodingKeys.type.rawValue)
        isIncome = try map.value(CodingKeys.isIncome.rawValue)
        name = try map.value(CodingKeys.name.rawValue)
        description = try map.value(CodingKeys.description.rawValue)
        category = try map.value(CodingKeys.category.rawValue)
        amount = try map.value(CodingKeys.amount.rawValue)
        currency = try map.value(CodingKeys.currency.rawValue)
        createdAt = try map.value(CodingKeys.createdAt.rawValue)
    }
    
    mutating func mapping(map: Map) { // .toJSON()
        type >>> map[CodingKeys.type.rawValue]
        isIncome >>> map[CodingKeys.isIncome.rawValue]
        name >>> map[CodingKeys.name.rawValue]
        description >>> map[CodingKeys.description.rawValue]
        category >>> map[CodingKeys.category.rawValue]
        amount >>> map[CodingKeys.amount.rawValue]
        currency >>> map[CodingKeys.currency.rawValue]
        createdAt >>> map[CodingKeys.createdAt.rawValue]
    }
}
